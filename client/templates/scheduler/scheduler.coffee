Template.scheduler.helpers
	calendarOptions: () ->
		{
			events: (start, end, timezone, callback) ->
      	callback Chips.find().map (el) ->
        		board = Boards.findOne(el.boardId)
        		el.title = board.title
        		el.color = board.config.bgColor
        		el
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
			eventDrop: (event, delta, revertFunc, jsEvent, ui, view ) ->
				console.log 'event drop'
			eventResize: ( event, jsEvent, ui, view ) ->
				console.log 'event resize'
		}


createChip = (start, end, boardId) ->
	Chips.insert { start: start, end: end, boardId: boardId }, (err, res) ->
		console.log err or res

Template.scheduler.onRendered ()->
	Chips.after.insert refetchEvents
	Chips.after.remove refetchEvents
	Chips.after.update refetchEvents
	
refetchEvents = () ->
	$('#calendar').fullCalendar 'refetchEvents'