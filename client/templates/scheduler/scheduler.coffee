Template.scheduler.helpers
	calendarOptions: () ->
		{
			defaultView: 'agendaWeek'
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