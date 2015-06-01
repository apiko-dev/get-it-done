Router.configure
	layoutTemplate : 'layout'

Router.route '/',
	name: 'home'

Router.route '/boards',
	name: 'boards'

Router.route '/scheduler',
	name: 'scheduler'