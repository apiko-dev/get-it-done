Template.home.onCreated ()->
  @.canPlay = new ReactiveVar false
  @.playing = new ReactiveVar false

Template.home.onRendered () ->
  @.video = $('video')[0]


Template.home.events
  'canplay video': (e, t) ->
    Template.instance().canPlay.set true
  'play video': (e, t) ->
    instance = Template.instance()
    instance.playing.set true
  'pause video': (e, t) ->
    instance = Template.instance()
    instance.playing.set false
  'ended video': (e, t) ->
    instance = Template.instance()
    instance.playing.set false
  'click .play': (e, t) ->
    Template.instance().video.play()
  'click .pause': (e, t) ->
    Template.instance().video.pause()
  'click .scroll-to-content': (e, t) ->
    $('html, body').animate
      scrollTop: $(".landing.content").offset().top
    , 400
  'click .get-started': (e, t) ->
    Router.go 'boards'


Template.home.helpers
  canPlay: () ->
    return Template.instance().canPlay.get()
  playing: () ->
    return Template.instance().playing.get()