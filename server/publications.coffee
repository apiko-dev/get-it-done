Meteor.publish 'userChips', ->
  Chips.find ownerId: @userId

Meteor.publish 'userBoards', ->
  Boards.find ownerId: @userId

Meteor.publish 'userTasks', ->
  Tasks.find ownerId: @userId

Meteor.publish '', ->
	Meteor.users.find {_id: @userId}, {fields: {toggl: 1, config: 1}}