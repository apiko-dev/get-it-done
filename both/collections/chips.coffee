@Chips = new Mongo.Collection 'chips'

Chips.allow
	insert: (userId, doc) ->
		userId && userId is doc.ownerId
	update: (userId, doc, fields, modifier) ->
		userId && userId is doc.ownerId
	remove: (userId, doc) ->
		userId && userId is doc.ownerId