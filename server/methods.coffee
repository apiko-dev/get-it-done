CurrentName = new Meteor.EnvironmentVariable;

setTaskTimer = (userId, taskId, timeEntry)->
	Tasks.update {ownerId: userId, timerStarted: 1}, {$set: {timerStarted: 0, timeEntry: null}}, {multi: 1}, (err, res) ->
		console.log err or res
		if taskId
			Tasks.update {_id: taskId}, {$set: {timerStarted: 1, timeEntry: timeEntry}}, ()->
				console.log err or res

Meteor.methods
	'toggl/createUser': (email, password)->
		check [email, password], [String]
		TogglClient.createUser email, password, (err, res) ->
			Meteor.users.update {_id: @.userId}, { $set: {'toggl.api_token': res.api_token} }
	'toggl/startTimer': (query) ->
		check query, 
			taskId: String,
			taskTitle: String
		if @.userId
			user = Meteor.users.findOne @.userId
			toggl = new TogglClient({apiToken: user.toggl.api_token})
			boundfunction = undefined
			CurrentName.withValue query, ()->
				boundfunction = Meteor.bindEnvironment (timeEntry)->
					setTaskTimer user._id, query.taskId, timeEntry
					return
				, (e) ->
					console.log e
			toggl.startTimeEntry { description: query.taskTitle }, (err, timeEntry) ->
				boundfunction(timeEntry)
	'toggl/stopTimer': () ->
		if @.userId
			user = Meteor.users.findOne @.userId
			task = Tasks.findOne timerStarted: 1, ownerId: @.userId
			toggl = new TogglClient({apiToken: user.toggl.api_token})
			boundfunction = undefined
			CurrentName.withValue user, ()->
				boundfunction = Meteor.bindEnvironment ()->
					setTaskTimer user._id
					return
				, (e) ->
					console.log e
			console.log 
			task.timeEntry and toggl.stopTimeEntry task.timeEntry.id, (err) ->
				boundfunction()