Router.configure
	layoutTemplate : 'layout'

Router.route '/',
	name: 'home'

Router.route '/boards',
	name: 'boards'
	waitOn: ->
		[ Meteor.subscribe('userBoards'), Meteor.subscribe('userTasks')]

Router.route '/scheduler',
	name: 'scheduler'
	waitOn: ->
		[ Meteor.subscribe('userBoards'), Meteor.subscribe('userChips')]
