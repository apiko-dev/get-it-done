CurrentName = new Meteor.EnvironmentVariable()

setTaskTimer = (userId, taskId, timeEntry) ->
  console.log 'setTaskTimer'
  Tasks.update {
    ownerId: userId
    timerStarted: 1
  }, { $set:
    timerStarted: 0
    timeEntry: null
    multi: 1 }, (err, res) ->
    console.log err or res
    if taskId
      return Tasks.update({ _id: taskId }, { $set:
        timerStarted: 1
        timeEntry: timeEntry }, ->
        console.log err or res
      )
    return

setBoardProject = (boardId, togglProject) ->
  Boards.update _id: boardId,
    $set:
      togglProject: togglProject
  , (err, res) ->
    console.log err or res

Meteor.methods
  'toggl/createUser': (email, password) ->
    check [email, password], [String]

    TogglClient.createUser email, password, (err, res) ->
      Meteor.users.update _id: @.userId,
        $set:
          'toggl.api_token': res.api_token

  'toggl/startTimer': (query) ->
    check query,
      taskId: String
      taskTitle: String
      boardId: String

    if @.userId
      user = Meteor.users.findOne @.userId

      if user.toggl and user.toggl.api_token
        board = Boards.findOne query.boardId

        if board and board.togglProject
          toggl = new TogglClient({apiToken: user.toggl.api_token})
          boundfunction = undefined

          CurrentName.withValue query, ->
            boundfunction = Meteor.bindEnvironment (timeEntry) ->
              setTaskTimer user._id, query.taskId, timeEntry
            , (e) -> console.log e

          toggl.startTimeEntry
            description: query.taskTitle
            pid: board.togglProject.id
          , (err, timeEntry) ->
            boundfunction(timeEntry)

  'toggl/stopTimer': ->
    if @.userId
      user = Meteor.users.findOne @.userId

      if signedInToToggl = user.toggl and user.toggl.api_token
        task = Tasks.findOne timerStarted: 1, ownerId: @.userId
        toggl = new TogglClient({apiToken: user.toggl.api_token})
        boundfunction = undefined

        CurrentName.withValue user, ->
          boundfunction = Meteor.bindEnvironment ->
            setTaskTimer user._id
          , (e) -> console.log e

        task.timeEntry and toggl.stopTimeEntry task.timeEntry.id, (err) ->
          boundfunction()

  'toggl/signIn': (email, password) ->
    check [email, password], [String]

    try
      resp = Wait.for HTTP.call, 'GET', 'https://www.toggl.com/api/v8/me', auth: email + ':' + password
    catch e

    if resp and resp.data and resp.data.data and resp.data.data.api_token
      api_token = resp.data.data.api_token
      Meteor.users.update _id: @.userId,
        $set:
          'toggl.api_token': api_token
    !!api_token

  'toggl/createProject': (query) ->
    check query,
      name: String
      boardId: String
      color: Match.Any

    if @.userId
      user = Meteor.users.findOne @.userId

      if user.toggl and user.toggl.api_token
        toggl = new TogglClient apiToken: user.toggl.api_token
        proj = Async.runSync (done) ->
          toggl.createProject
            name: query.name
            color: query.color
            wid: 0
          , (err, res) ->
            done err, res

        Async.runSync (done) ->
          Boards.update
            _id: query.boardId,
            $set:
              togglProject: proj.result
          , (err, res) ->
            done(err, res)

  'toggl/updateProject': (query) ->
    if @.userId
      user = Meteor.users.findOne @.userId

      if user.toggl and user.toggl.api_token
        toggl = new TogglClient apiToken: user.toggl.api_token
        toggl.updateProject query.projectId, query.data, (err, res) ->
          err and console.log err

  'toggl/getWorkspaces': ->
    resp = undefined

    if @.userId
      user = Meteor.users.findOne @.userId

      if user.toggl and user.toggl.api_token
        toggl = new TogglClient {apiToken: user.toggl.api_token}
        resp = Async.runSync (done) ->
          toggl.getWorkspaces (err, res) ->
            done err, res
    resp

  'toggl/getProjects': (wid) ->
    resp = undefined

    if @.userId
      user = Meteor.users.findOne @.userId

      if user.toggl and user.toggl.api_token
        toggl = new TogglClient apiToken: user.toggl.api_token
        resp = Async.runSync (done) ->
          toggl.getWorkspaceProjects wid, (err, res) ->
            done err, res
    resp

  'gcalendar/fetchEvents': (calendarId) ->
    resp = undefined

    if @.userId
      user = Meteor.users.findOne @.userId

      if user.services and user.services.google and googleAccessToken = user.services.google.accessToken
        gc = new GCalendar.GoogleCalendar googleAccessToken
        resp = Async.runSync (done) ->
          gc.events.list calendarId, (err, res) ->
            done err, res
    resp

  'gcalendar/fetchCalendars': ->
    resp = undefined

    if @.userId
      user = Meteor.users.findOne @.userId

      if user.services and user.services.google and googleAccessToken = user.services.google.accessToken
        gc = new GCalendar.GoogleCalendar googleAccessToken
        resp = Async.runSync (done) ->
          gc.calendarList.list (err, res) ->
            done err, res
    resp

  'user/setTogglWorkspace': (workspaceId) ->
    userId = @.userId
    Async.runSync (done) ->
      Meteor.users.update {_id: userId}, {$set: {'toggl.workspaceId': workspaceId}}, (err, res) ->
        err and console.log err
        done err, res