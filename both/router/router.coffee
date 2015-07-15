Router.route '/',
	name: 'home'

Router.route '/boards',
	name: 'boards'
	layoutTemplate : 'layout'
	waitOn: ->
		[ Meteor.subscribe('userBoards'), Meteor.subscribe('userTasks')]

Router.route '/scheduler',
	name: 'scheduler'
	layoutTemplate : 'layout'
	waitOn: ->
		[ Meteor.subscribe('userBoards'), Meteor.subscribe('userChips'), Meteor.subscribe('userTasks')]
