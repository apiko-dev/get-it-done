CurrentName = new Meteor.EnvironmentVariable;

setTaskTimer = (userId, taskId, timeEntry)->
	Tasks.update {ownerId: userId, timerStarted: 1}, {$set: {timerStarted: 0, timeEntry: null}}, {multi: 1}, (err, res) ->
		console.log err or res
		if taskId
			Tasks.update {_id: taskId}, {$set: {timerStarted: 1, timeEntry: timeEntry}}, ()->
				console.log err or res

setBoardProject = (boardId, togglProject)->
	Boards.update {_id: boardId}, {$set: {togglProject: togglProject}}, (err, res) ->
		console.log err or res

setWorkspace = (userId, workspace)->
	Boards.update {_id: boardId}, {$set: {togglProject: togglProject}}, (err, res) ->
		console.log err or res

Meteor.methods
	'toggl/createUser': (email, password)->
		check [email, password], [String]
		TogglClient.createUser email, password, (err, res) ->
			Meteor.users.update {_id: @.userId}, { $set: {'toggl.api_token': res.api_token} }
	'toggl/startTimer': (query) ->
		check query, 
			taskId: String
			taskTitle: String
			boardId: String
		if @.userId
			user = Meteor.users.findOne @.userId
			if user.toggl and user.toggl.api_token
				board = Boards.findOne query.boardId
				toggl = new TogglClient({apiToken: user.toggl.api_token})
				boundfunction = undefined
				CurrentName.withValue query, ()->
					boundfunction = Meteor.bindEnvironment (timeEntry)->
						setTaskTimer user._id, query.taskId, timeEntry
						return
					, (e) ->
						console.log e
				toggl.startTimeEntry { description: query.taskTitle, pid: board.togglProject.id }, (err, timeEntry) ->
					boundfunction(timeEntry)
	'toggl/stopTimer': () ->
		if @.userId
			user = Meteor.users.findOne @.userId
			if user.toggl and user.toggl.api_token
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
	'toggl/signIn': (email, password) ->
		check [email, password], [String]
		api_token
		try
			resp = Wait.for HTTP.call, 'GET', 'https://www.toggl.com/api/v8/me', { auth: email + ':' + password }
		catch e
		if resp and resp.data and resp.data.data and resp.data.data.api_token
			api_token = resp.data.data.api_token
			Meteor.users.update {_id: @.userId}, {$set: {'toggl.api_token': api_token}}
		!!api_token
	'toggl/createProject': (query) ->
		check query, 
			name: String
			boardId: String
			color: Match.Any
		if @.userId 
			user = Meteor.users.findOne @.userId
			if user.toggl and user.toggl.api_token
				toggl = new TogglClient({apiToken: user.toggl.api_token})
				boundfunction = undefined
				CurrentName.withValue query, ()->
					boundfunction = Meteor.bindEnvironment (togglProject)->
						setBoardProject query.boardId, togglProject
						return
					, (e) ->
						console.log e
				toggl.createProject { name: query.name, color: query.color, wid: 0 }, (err, togglProject) ->
					console.log err or togglProject
					boundfunction(togglProject)
	'toggl/updateProject': (query)->
		if @.userId 
			user = Meteor.users.findOne @.userId
			if user.toggl and user.toggl.api_token
				toggl = new TogglClient {apiToken: user.toggl.api_token}
				toggl.updateProject query.projectId, query.data, (err, res) ->
					err and console.log err

	'gcalendar/fetchEvents': (query)->
		
