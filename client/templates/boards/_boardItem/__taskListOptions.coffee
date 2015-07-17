@taskListOptions =
  connectWith: '.task-list'
  helper: 'clone'
  placeholder: 'sortable-placeholder'
  items: '.action'
  forcePlaceholderSize: yes
  dropOnEmpty: yes
  opacity: 1
  zIndex: 99999
  start: (e, ui) ->
    ui.placeholder.height ui.helper.outerHeight()
  update: (event, ui) ->
    targetBoardId = Blaze.getData(event.target)._id
    targetTaskId = ui.item[0].dataset.id
    try
      prevTaskData = ui.item[0].previousElementSibling.dataset
    try
      nextTaskData = ui.item[0].nextElementSibling.dataset
    if not nextTaskData and !!prevTaskData and !!prevTaskData.order
      curOrder = Number prevTaskData.order + 1
      console.log '------ prew'
    if not prevTaskData and !!nextTaskData and !!nextTaskData.order
      curOrder = Number nextTaskData.order / 2
      console.log '------ next'
    if not prevTaskData and not nextTaskData
      curOrder = 1
      console.log '------ empty'
    if !!prevTaskData and !!prevTaskData.order and !!nextTaskData and !!nextTaskData.order
      curOrder = (nextTaskData.order + prevTaskData.order) / 2
      console.log '------ all'
    console.log 'curOrder',curOrder
    console.log 'prevTaskData',prevTaskData
    console.log 'nextTaskData',nextTaskData
    updateTask targetTaskId, boardId: targetBoardId, order: curOrder