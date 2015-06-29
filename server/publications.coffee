Meteor.publish 'userChips', ->
  return Chips.find ownerId: @userId

Meteor.publish 'userBoards', ->
  return Boards.find ownerId: @userId

Meteor.publish 'userTasks', ->
  return Tasks.find ownerId: @userId

Meteor.publish '', ->
	return Meteor.users.find {_id: @userId}, {fields: {toggl: 1, config: 1}}