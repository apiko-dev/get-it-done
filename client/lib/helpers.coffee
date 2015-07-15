@COLORS = [
  '#4dc3ff'
  '#bc85e6'
  '#df7baa'
  '#f68d38'
  '#b27636'
  '#8ab734'
  '#14a88e'
  '#268bb5'
  '#6668b4'
  '#a4506c'
  '#67412c'
  '#3c6526'
  '#094558'
  '#bc2d07'
  '#999999'
]

@PRIORITY_CLASSES = [
  'LOW'
  'MED'
  'HIGH'
]

Template.registerHelper 'colorByKey', (key) ->
  COLORS[Number(key)]

Template.registerHelper 'equals', (a, b) ->
  a == b

Template.registerHelper 'isCurrentProject', (board, togglProjectId) ->
  board.togglProject and board.togglProject.id == togglProjectId

@fetchProjects = ->
  user = Meteor.user()
  if user and user.toggl and user.toggl.workspaceId
    Meteor.call 'toggl/getProjects', user.toggl.workspaceId, (err, res) ->
      if res and res.result
        res.result.forEach (el) ->
          if !TogglProjects.findOne(name: el.name)
            TogglProjects.insert el

Template.registerHelper 'trimLongText', (text, symbols) ->
  if symbols < text.length
    return text.slice(0, symbols - 2) + '...'
  text.slice 0, symbols
