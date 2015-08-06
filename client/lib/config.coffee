Accounts.ui.config
  forceApprovalPrompt: true
  requestPermissions:
    google: [
      'openid'
      'email'
      'https://www.googleapis.com/auth/calendar'
      'https://www.googleapis.com/auth/calendar.readonly'
    ]
  requestOfflineToken:
    google: true
#  forceApprovalPrompt:
#    google: true

Meteor.startup ->
  sAlert.config
    effect: 'stackslide'
    position: 'top'
    timeout: 1000
    html: false
    onRouteClose: true
    stack: false
    offset: 0