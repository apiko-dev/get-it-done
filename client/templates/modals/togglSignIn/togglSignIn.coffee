Template.togglSignIn.onCreated ->
  @.showSpinner = new ReactiveVar false
  @.signInFailed = new ReactiveVar false
  @.workspaces = new ReactiveVar()

Template.togglSignIn.onRendered ->
  fetchWorkspaces @
  enadleDropdown @

Template.togglSignIn.events
  'submit .toggl-sign-in': (e) ->
    e.preventDefault()
    self = Template.instance()
    if signedInToToggl = Meteor.user().toggl and Meteor.user().toggl.api_token
      workspaceId = e.target[0].value
      Meteor.call 'user/setTogglWorkspace', workspaceId, (err, res) ->
        if res and res.result
          $('#togglSignInModal').modal 'hide'
        err and console.log err
    else
      self.showSpinner.set true
      self.signInFailed.set false
      email = e.target[0].value
      password = e.target[1].value
      if email and password
        Meteor.call 'toggl/signIn', email, password, (err) ->
          self.showSpinner.set false
          if err
            self.signInFailed.set true
          else
            fetchWorkspaces(self)
  'click .submit': () ->
    $('.toggl-sign-in').submit()


Template.togglSignIn.helpers
  showSpinner: ->
    Template.instance().showSpinner.get()
  signInFailed: ->
    Template.instance().signInFailed.get()
  workspaces: ->
    Template.instance().workspaces.get()

fetchWorkspaces = (instance) ->
  if Meteor.user().toggl and Meteor.user().toggl.api_token
    Meteor.call 'toggl/getWorkspaces', (err, res) ->
      if res and res.result
        instance.workspaces.set res.result
        enadleDropdown instance

enadleDropdown = (instance) ->
  if Meteor.user().toggl and Meteor.user().toggl.api_token
    Meteor.setTimeout () ->
      instance.$('.dropdown-toggle').dropdown()
    , 500