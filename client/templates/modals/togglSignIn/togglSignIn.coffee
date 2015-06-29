Template.togglSignIn.onCreated ()->
	@.showSpinner = new ReactiveVar(false);
	@.signInFailed = new ReactiveVar(false);

Template.togglSignIn.events
	'submit .toggl-sign-in': (e, t) ->
		self = Template.instance()
		self.showSpinner.set true
		self.signInFailed.set false
		e.preventDefault()
		email = e.target[0].value
		password = e.target[1].value
		if email and password
			Meteor.call 'toggl/signIn', email, password, (err, res) ->
				self.showSpinner.set false
				if res
					$('#togglSignInModal').modal 'hide'
				else
					self.signInFailed.set true
	'click .submit': (e, t) ->
		$('.toggl-sign-in').submit()


Template.togglSignIn.helpers
	showSpinner:  ()->
		return Template.instance().showSpinner.get()
	signInFailed: () ->
		return Template.instance().signInFailed.get()

