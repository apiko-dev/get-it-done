Template.scheduler.helpers
	calendarOptions: () ->
		{
			events: (start, end, timezone, callback) ->
				console.log Chips.find().map (el) ->
        		board = Boards.findOne(el.boardId)
        		el.title = board.title
        		el.color = board.config.bgColor
        		el
      	callback Chips.find().map (el) ->
        		board = Boards.findOne(el.boardId)
        		el.title = board.title
        		el.color = board.config.bgColor
        		el
			defaultView: 'agendaWeek'
			allDaySlot: false
			overlap: true
			id: 'calendar'
			header: {
				left:   'title',
				center: '',
				right:  'month,agendaWeek today prev,next'
			}
			timezone: 'local'
			selectable: true
			select: ( start, end, jsEvent, template ) ->
				Modal.show 'newChipModal', 
					start: start
					end: end
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