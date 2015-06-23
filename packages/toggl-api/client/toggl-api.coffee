TogglClientSide = 
	startTimer: (query, cb) ->
		check query,
			taskTitle: String
		Meteor.call 'toggl/startTimer', query, (err, res)->
			if cb and typeof cb == 'function'
				console.log 'package start timer'
				cb.apply @, [err, res]
	stopTimer: (cb)->
		Meteor.call 'toggl/stopTimer', (err, res)->
			if cb and typeof cb == 'function'
				console.log 'package stop timer'
				cb.apply @, [err, res]