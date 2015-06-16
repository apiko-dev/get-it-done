Template.boards.helpers
	boards: () ->
		return Boards.find ownerId: Meteor.userId()
	boardCreating: () ->
		return Template.instance().boardCreating.get()

Template.boards.onCreated (->
	@.boardCreating = new ReactiveVar(false);
)

Template.boards.onRendered (->
	$('.new-board-container.dropdown-toggle').dropdown()
	hash = Router.current().params.hash
	if hash
		Meteor.setTimeout () ->
				console.log hash
  		location.hash = "#" + hash
    return 
		, 1000
)

Template.boards.events
	'click .new-board-action': () ->
		Template.instance().boardCreating.set true
	'click .new-board-cancel-action': () ->
		Template.instance().boardCreating.set false
	'click .new-board-ok-action': (e, t) ->
		text = $(e.target).parent().parent().find('textarea').val()
		if !text or !text.length
			alert 'Board name is required'
		Boards.insert {ownerId: Meteor.userId(), title: text}, (err, res) ->
			console.log err or res
		Template.instance().boardCreating.set false