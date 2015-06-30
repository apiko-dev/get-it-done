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
    , 100
  @.$('#lists').sortable
    helper: 'clone'
    placeholder: 'sortable-placeholder'
    items: '.board'
    forcePlaceholderSize: !0
    distance: 5
    dropOnEmpty: true
    opacity: 1
    zIndex: 1000
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
  'click .new-board-action': (e, t) ->
    Template.instance().boardCreating.set true
    #$('#cmcwyzqrJfBHEWDnE > div.container').stop().animate scrollTop: $('#cmcwyzqrJfBHEWDnE > div.container > div.row.action.new-task-container').offset().left
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