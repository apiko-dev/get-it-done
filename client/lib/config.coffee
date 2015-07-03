Accounts.ui.config
  requestPermissions: google: [ 'https://www.googleapis.com/auth/calendar' ]
  forceApprovalPrompt: google: true

Meteor.startup ->
  sAlert.config
    effect: 'stackslide'
    position: 'top'
    timeout: 1000
    html: false
    onRouteClose: true
    stack: false
    offset: 0