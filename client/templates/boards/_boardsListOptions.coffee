@boardsListOptions =
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
    ui.placeholder.height ui.helper.outerHeight()
  update: (event, ui) ->
    targetBoardId = Blaze.getData(ui.item[0])._id
    try
      prevBoardData = Blaze.getData ui.item[0].previousElementSibling
    try
      nextBoardData = Blaze.getData ui.item[0].nextElementSibling
    if !nextBoardData and prevBoardData
      curOrder = prevBoardData.order + 1
    if !prevBoardData and nextBoardData
      curOrder = nextBoardData.order / 2
    if !prevBoardData and !nextBoardData
      curOrder = 1
    if prevBoardData and nextBoardData
      curOrder = (nextBoardData.order + prevBoardData.order) / 2

    updateBoard targetBoardId, order: curOrder