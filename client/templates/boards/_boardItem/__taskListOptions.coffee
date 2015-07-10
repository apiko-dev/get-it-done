@taskListOptions =
  connectWith: '.task-list'
  helper: 'clone'
  placeholder: 'sortable-placeholder'
  items: '.action'
  forcePlaceholderSize: yes
  dropOnEmpty: yes
  opacity: 1
  zIndex: 9999
  start: (e, ui) ->
    ui.placeholder.height ui.helper.outerHeight()
  update: (event, ui) ->
    targetBoardId = Blaze.getData(event.target)._id
    targetTaskId = ui.item[0].dataset.id
    try
      prevTaskData = ui.item[0].previousElementSibling.dataset
    try
      nextTaskData = ui.item[0].nextElementSibling.dataset
    if !nextTaskData and prevTaskData
      curOrder = Number prevTaskData.order + 1
    if !prevTaskData and nextTaskData
      curOrder = Number nextTaskData.order / 2
    if !prevTaskData and !nextTaskData
      curOrder = 1
    if prevTaskData and nextTaskData
      curOrder = (nextTaskData.order + prevTaskData.order) / 2

    updateTask targetTaskId, boardId: targetBoardId, order: curOrder