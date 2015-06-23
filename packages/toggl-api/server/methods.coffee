CurrentName = new Meteor.EnvironmentVariable;

updateUser = (userId, timeEntry) ->
	Meteor.users.update {_id: userId}, {$set: {'toggl.timeEntry': timeEntry}}

Meteor.methods
	'toggl/createUser': (email, password)->
		check [email, password], [String]
		TogglClient.createUser email, password, (err, res) ->
			Meteor.users.update {_id: @.userId}, { $set: {'toggl.api_token': res.api_token} }
	'toggl/startTimer': (query) ->
		if @.userId
			check query,
				taskTitle: String
			user = Meteor.users.findOne @.userId
			toggl = new TogglClient({apiToken: user.toggl.api_token})
			boundfunction = undefined
			CurrentName.withValue query, ()->
				boundfunction = Meteor.bindEnvironment (timeEntry)->
					updateUser user._id, timeEntry
					return
				, (e) ->
					console.log e
			toggl.startTimeEntry { description: query.taskTitle }, (err, timeEntry) ->
				boundfunction(timeEntry)
	'toggl/stopTimer': () ->
		if @.userId
			user = Meteor.users.findOne @.userId
			toggl = new TogglClient({apiToken: user.toggl.api_token})
			boundfunction = undefined
			CurrentName.withValue user, ()->
				boundfunction = Meteor.bindEnvironment ()->
					updateUser user._id, null
					return
				, (e) ->
					console.log e
			user.toggl.timeEntry and toggl.stopTimeEntry user.toggl.timeEntry.id, (err) ->
				boundfunction()
