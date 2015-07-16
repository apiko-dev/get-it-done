lastPosition = undefined

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
    clonedItems = undefined
    ui.helper.addClass 'being-dragged'
    clonedItems = $('#cloned_items')
    $('.task-list .action:not(.being-dragged, .ui-sortable-placeholder, .fixed)').each ->
      clone = undefined
      original = undefined
      position = undefined
      original = $(this)
      clone = original.clone()
      original.data 'clone', clone
      original.css 'visibility', 'hidden'
      position = original.position()
      clone.css('left', position.left).css 'top', position.top
      clonedItems.append clone

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

  change: (e, ui) ->
    $helper = undefined
    $sortable = undefined
    $statics = undefined
    $sortable = $(this)
    $statics = $('.fixed', this).detach()
    $helper = $('<div class="portlet" style="background-color:#000"></div>').prependTo(this)
    $statics.each ->
      $this = undefined
      target = undefined
      $this = $(this)
      target = $this.data('pos')
      $this.insertAfter $('.action', $sortable).eq(target)
    $helper.remove()
    $('.task-list .action:not(.being-dragged, .ui-sortable-placeholder, .fixed)').each ->
      clone = undefined
      item = undefined
      position = undefined
      item = $(this)
      clone = item.data('clone')
      clone.stop true, false
      position = item.position()
      clone.animate {
        left: position.left
        top: position.top
      }, 500

  stop: (e, ui) ->
    el = undefined
    newPosition = undefined
    console.log lastPosition
    el = $('.task-list .being-dragged')
    newPosition = el.position()
    $('<div class="portlet ui-sortable-placeholder"></div>').insertBefore el
    el.css('left', lastPosition.left).css('top', lastPosition.top).css('position', 'absolute').animate({
      left: newPosition.left
      top: newPosition.top
    }, 300, 'swing', ->
      $('.task-list .ui-sortable-placeholder').remove()
      $(this).css('left', '').css('top', '').css 'position', ''
      return
    ).removeClass 'being-dragged'
    $('#cloned_items').empty()
    $('.task-list .action').css 'visibility', 'visible'

$('.action').on 'mouseup', ->
  lastPosition = $(this).position()
  return
$('.task-list').disableSelection()
$('.action').addClass('ui-widget ui-widget-content ui-helper-clearfix ui-corner-all').find('.action-header').addClass('ui-widget-header ui-corner-all').prepend('<span class=\'ui-icon ui-icon-minusthick\'></span>').end().find '.action-content'
$('.action-header .ui-icon').click ->
  $(this).toggleClass('ui-icon-minusthick').toggleClass 'ui-icon-plusthick'
  $(this).parents('.action:first').find('.action-content').toggle()
  return