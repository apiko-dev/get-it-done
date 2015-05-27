Template.boards.helpers
	boards: () ->
		return Boards.find ownerId: Meteor.userId()