EVENT_REMOVE_BUTTON = '<div class="event-ctrls"><span class="remove-event"><i class="fa fa-minus"></i></span></div>'

Meteor.Spinner.options =
  radius: 3
  color: '#666'
  top: '10px'
  left: '0px'
  lines: 15
  length: 5
  width: 1
  speed: 3
  'z-index': 9

Template.scheduler.onCreated ->
  @calendars = new ReactiveVar()
  calendarsCount = GCCalendars.find().count()
  @showSpinner = new ReactiveVar not calendarsCount

Template.scheduler.onRendered ->
  displayCurrentTimeRuler()
  if tableIsPresent = $("#calendar table").length > 0
    $("#calendar table").eq(0).fixedTableHeader()

Template.scheduler.helpers
  boards: ->
    Boards.find
      ownerId: Meteor.userId()
      isBacklog:
        $exists: false
    , sort: {order: 1}

  backlogBoard: ->
    Boards.findOne isBacklog: true

  calendarOptions: ->
    {
    eventRender: (event, element) ->
      if not event.isGoogle
        element.append EVENT_REMOVE_BUTTON
      if event.isGoogle
        element.addClass "gc-event"
      if event.tasks?
        element.append "<div class=\"event-tasks\">#{event.tasks?.join ", "}"
    events: (start, end, timezone, callback) ->
      allEvents = Chips.find().map (el) ->
        board = Boards.findOne el.boardId
        #fetch task names to event
        if el.taskIds?
          el.tasks = []
          for taskId in el.taskIds
            try
              el.tasks.push Tasks.findOne(_id: taskId).text
            catch e
            #task is probably removed
        el.title = board.title
        el.color = COLORS[board.config.bgColor]
        el
      googleEvents = GCEvents.find().fetch()
      if googleEvents
        allEvents = allEvents.concat googleEvents
      callback allEvents
    defaultView: 'agendaWeek'
    allDaySlot: false
    editable: true
    overlap: true
    height: "auto"
    id: 'calendar'
    header: {
      left: 'title',
      center: '',
      right: 'month,agendaWeek,agendaDay today prev,next'
    }
    timezone: 'local'
    selectable: true
    select: (start, end, jsEvent, template) ->
      Modal.show 'newChipModal',
        start: start
        end: end
    eventDrop: (event, delta, revertFunc, jsEvent, ui, view) ->
      updateChip event
    eventResize: (event, jsEvent, ui, view) ->
      updateChip event
    eventClick: (event, jsEvent, view) ->
      if not event.isGoogle
        className = jsEvent.target.className
        if className is 'remove-event' or className is 'fa fa-minus'
          Chips.remove {_id: event._id}, (err, res) ->
            console.log err or res
        else
          Router.go 'boards', {},
            hash: event.boardId
    }
  calendars: ->
    GCCalendars.find()
  showSpinner: ->
    Template.instance().showSpinner.get()

Template.scheduler.onRendered ->
  fetchGCCalendars()

  Meteor.setTimeout ->
    refetchEvents()
  , 100

  Chips.after.insert refetchEvents
  Chips.after.remove refetchEvents
  Chips.after.update refetchEvents

  @.$('.dropdown-toggle').dropdown()

Template.scheduler.events
  'click .choosable-calendar-item': (e) ->
    calendar = Blaze.getData e.target
    events = GCEvents.find calendarId: calendar.id
    if events.count() < 1
      fetchGCEvents calendar.id
    else
      removeGCEventsByCalendarId calendar.id
    GCCalendars.update _id: calendar._id,
      $set:
        active: not calendar.active

refetchEvents = ->
  $('#calendar').fullCalendar 'refetchEvents'

updateChip = (event) ->
  Chips.update _id: event._id,
    $set:
      start: event.start.format()
      end: event.end.format()
  , (err, res) ->
    console.log err or res

createChip = (start, end, boardId) ->
  Chips.insert {start: start, end: end, boardId: boardId}, (err, res) ->
    console.log err or res

fetchGCEvents = (calendarId) ->
  Meteor.call 'gcalendar/fetchEvents', calendarId, (err, res) ->
    console.log err or res
    if res and res.result
      res.result.items.forEach (el) ->
        if el.start and el.start.dateTime and el.end and el.end.dateTime
          GCEvents.insert
            start: el.start.dateTime
            end: el.end.dateTime
            title: el.summary
            isGoogle: true
            color: 'rgba(69, 158, 203, 0.55)'
            calendarId: calendarId
      refetchEvents()

fetchGCCalendars = ->
  tplInstance = Template.instance()
  if noGoogleCalendars = GCCalendars.find().count() < 1
    Meteor.call 'gcalendar/fetchCalendars', (err, res) ->
      if res and res.result
        res.result.items.forEach (el) ->
          el.active = false
          GCCalendars.insert el
        tplInstance.showSpinner.set false

removeGCEventsByCalendarId = (calendarId) ->
  GCEvents.remove calendarId: calendarId, (err, res) ->
    console.log err or res
    refetchEvents()

displayCurrentTimeRuler = ->
  hr = $ '<hr>'
  hr.attr "id", "cur-time-ruler"
  container = $ '.fc-time-grid'

  rulerPosition = $('td.fc-today').position()
  rulerWidth = $('td.fc-today').width()

  unit = container.height() / (24 * 60) #pixel per minute
  curTime = new Date()
  minutesAfterMidnight = curTime.getHours() * 60 + curTime.getMinutes()

  if rulerPosition
    hr.css 'top', minutesAfterMidnight * unit + 'px'
    hr.css 'left', rulerPosition.left
    hr.css 'width', rulerWidth
    hr.css 'z-index', 12
    container.append hr

  #TODO What if page isn't reloaded for a day
  #Need to update left position too
  Meteor.setInterval ->
    hr.css 'top', hr.height + unit + 'px'
    console.log hr
  , 60000