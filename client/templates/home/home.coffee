Template.home.onCreated ()->
  @.canPlay = new ReactiveVar false
  @.playing = new ReactiveVar false
  @.showSpinner = new ReactiveVar false

Template.home.onRendered () ->
  @.video = $('video')[0]

Template.home.events
  'canplay .landing-video': () ->
    Template.instance().canPlay.set true
  'play .landing-video': () ->
    instance = Template.instance()
    instance.playing.set true
  'pause .landing-video': () ->
    instance = Template.instance()
    instance.playing.set false
  'ended .landing-video': () ->
    instance = Template.instance()
    instance.playing.set false
  'click .play': () ->
    Template.instance().video.play()
  'click .pause': () ->
    Template.instance().video.pause()
  'click .scroll-to-content': () ->
    $('html, body').animate
      scrollTop: $(".landing.content").offset().top - 60
    , 400
  'click .get-started': () ->
    Router.go 'boards'
  'mouseover article video': (e) ->
    e.target.play()
  'mouseleft article video': (e) ->
    e.target.pause()
  'click #subscribe button.submit': (e) ->
    instance = Template.instance()
    instance.showSpinner.set true
    email = $(e.target.parentElement).find('#email').val()
    if not validateEmail email
      sAlert.error 'Invalid email'
    else
      Emails.insert
        email: email
      , (err, res) ->
        instance.showSpinner.set false
        if res
          sAlert.info 'You successfully subscribed to updates'
        else
          sAlert.warning 'This email is already registered'
          console.log err


Template.home.helpers
  canPlay: () ->
    return Template.instance().canPlay.get()
  playing: () ->
    return Template.instance().playing.get()
  showSpinner: ()->
    return Template.instance().showSpinner.get()

validateEmail = (email) ->
  re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
  re.test email