EVENT_CTRLS = '<div class="event-ctrls"><span class="remove-event"><i class="fa fa-minus"></i></span></div>'

Meteor.Spinner.options =
	width: 5
	radius: 3
	color: '#666'
	top: '10px'
	left: '0px'
	lines: 15
	length: 5
	width: 1
	speed: 3

Template.scheduler.onCreated ()->
	@calendars = new ReactiveVar()
	@showSpinner = new ReactiveVar true
	self = @

Template.scheduler.helpers
	calendarOptions: () ->
		{
			eventRender: (event, element) ->
        element.append EVENT_CTRLS
			events: (start, end, timezone, callback) ->
				allEvents = Chips.find().map (el) ->
			  	board = Boards.findOne(el.boardId)
			  	el.title = board.title
			  	el.color = COLORS[board.config.bgColor]
			  	el
				googleEvents = GCEvents.find().fetch()
				if googleEvents
					allEvents = allEvents.concat googleEvents
				console.log 'allEvents', allEvents
				console.log 'googleEvents', googleEvents
				console.log 'allEvents', allEvents
				callback allEvents
			defaultView: 'agendaWeek'
			allDaySlot: false
			editable: true
			overlap: true
			height: "auto"
			id: 'calendar'
			header: {
				left:   'title',
				center: '',
				right:  'month,agendaWeek,agendaDay today prev,next'
			}
			timezone: 'local'
			selectable: true
			select: ( start, end, jsEvent, template ) ->
				Modal.show 'newChipModal', 
					start: start
					end: end
				console.log start
			eventDrop: (event, delta, revertFunc, jsEvent, ui, view ) ->
				updateChip event
			eventResize: ( event, jsEvent, ui, view ) ->
				updateChip event
			eventClick: ( event, jsEvent, view ) ->
				if not event.isGoogle
					className = jsEvent.target.className
					if className == 'remove-event' or className == 'fa fa-minus'
						Chips.remove {_id: event._id}, (err, res) ->
							console.log err or res
					else
						Router.go 'boards', { },
							hash: event.boardId
						#console.log 'go to board ', event.boardId
		}
	calendars: () ->
		return GCCalendars.find()
	showSpinner: ()->
		return Template.instance().showSpinner.get()

Template.scheduler.onRendered ()->
	fetchGCCalendars()
	Meteor.setTimeout (->
  	refetchEvents()
	), 100
	Chips.after.insert refetchEvents
	Chips.after.remove refetchEvents
	Chips.after.update refetchEvents
	@.$('.dropdown-toggle').dropdown()


Template.scheduler.events
	'click .choosable-calendar-item': (e, t)->
		calendar = Blaze.getData e.target
		events = GCEvents.find( calendarId: calendar.id )
		console.log 'eventsCount', events.count()
		if events.count() < 1
			fetchGCEvents calendar.id
		else
			removeGCEventsByCalendarId calendar.id
		GCCalendars.update {_id: calendar._id}, {$set: {active: not calendar.active}}
	
refetchEvents = () ->
	$('#calendar').fullCalendar 'refetchEvents'

updateChip = (event) ->
	Chips.update {_id: event._id}, {$set: {start: event.start.format(), end: event.end.format()}}, (err, res) ->
		console.log err or res

createChip = (start, end, boardId) ->
	Chips.insert { start: start, end: end, boardId: boardId }, (err, res) ->
		console.log err or res

fetchGCEvents = (calendarId) ->
	Meteor.call 'gcalendar/fetchEvents', calendarId, (err, res) ->
		console.log err or res
		if res and res.result
			res.result.items.forEach (el)->
				if el.start and el.start.dateTime and el.end and el.end.dateTime
					GCEvents.insert
						start: el.start.dateTime#new Date el.start.dateTime
						end: el.end.dateTime#new Date el.end.dateTime
						title: el.summary
						isGoogle: true
						calendarId: calendarId
			refetchEvents()

fetchGCCalendars = () ->
	instance = Template.instance()
	if GCCalendars.find().count() < 1
		Meteor.call 'gcalendar/fetchCalendars', (err, res) ->
			if res and res.result
				res.result.items.forEach (el)->
					el.active = false
					GCCalendars.insert el
				instance.showSpinner.set false

removeGCEventsByCalendarId = (calendarId) ->
	GCEvents.remove calendarId: calendarId, (err, res) ->
		console.log err or res
		refetchEvents()