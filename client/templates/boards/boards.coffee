Template.boards.helpers
	boards: () ->
		return Boards.find { ownerId: Meteor.userId() }, sort: order: 1
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
  		$('#lists').stop().animate { scrollLeft: $('#'+hash).offset().left }, 1000
    return 
		, 100
	@.$('#lists').sortable
		connectWith: '#lists'
		helper: 'clone'
		placeholder: 'sortable-placeholder'
		items: '.board'
		forcePlaceholderSize: !0
		dropOnEmpty: true
		opacity: 1
		zIndex: 9999
		cursorAt: 
      top: 100,
      left: 190
    axis: 'x'
		start: (e, ui) ->
		  #ui.placeholder.height(ui.helper.outerHeight());
		update: (event, ui) ->
			targetBoardId = Blaze.getData(ui.item[0])._id
			try
				prevBoardData = Blaze.getData ui.item[0].previousElementSibling
			try
				nextBoardData = Blaze.getData ui.item[0].nextElementSibling
			if !nextBoardData and prevBoardData
				curOrder = prevBoardData.order + 1
			if !prevBoardData and nextBoardData
				curOrder = nextBoardData.order/2
			if !prevBoardData and !nextBoardData
				curOrder = 1
			if prevBoardData and nextBoardData
				curOrder = (nextBoardData.order + prevBoardData.order) / 2
			Boards.update { _id: targetBoardId }, { $set: order: curOrder}, (err, res) ->
				console.log err or res
)

Template.boards.events
	'click .new-board-action': () ->
		Template.instance().boardCreating.set true
	'click .new-board-cancel-action': () ->
		Template.instance().boardCreating.set false
	'click .new-board-ok-action, keydown .board-title': (e, t) ->
		if e.type == 'click' or e.keyCode == 13
			text = $(e.target).closest('.new-board-container').find('input').val()
			if !text or !text.length
				alert 'Board name is required'
			Boards.insert {ownerId: Meteor.userId(), title: text}, (err, res) ->
				console.log err or res
			Template.instance().boardCreating.set false