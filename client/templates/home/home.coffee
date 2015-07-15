Template.home.onCreated ()->
  @.canPlay = new ReactiveVar false
  @.playing = new ReactiveVar false
  @.ended = new ReactiveVar false

Template.home.onRendered () ->
  @.video = $('video')[0]


Template.home.events
  'canplay video': (e, t) ->
    Template.instance().canPlay.set true
  'play video': (e, t) ->
    instance = Template.instance()
    instance.playing.set true
    instance.ended.set false
  'ended video': (e, t) ->
    instance = Template.instance()
    instance.ended.set true
    instance.playing.set false
  'click .play': (e, t) ->
    Template.instance().video.play()
  'click .scroll-to-content': (e, t) ->
    $('html, body').animate
      scrollTop: $(".landing.content").offset().top
    , 400


Template.home.helpers
  canPlay: () ->
    return Template.instance().canPlay.get()
  playing: () ->
    return Template.instance().playing.get()
  ended: () ->
    return Template.instance().ended.get()