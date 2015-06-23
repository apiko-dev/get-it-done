#@Secrets = new Mongo.Collection 'secrets'
#
#Secrets.allow
#	insert: (userId, doc) ->
#		userId && userId is doc.ownerId
#	update: (userId, doc, fields, modifier) ->
#		userId && userId is doc.ownerId
#	remove: (userId, doc) ->
#		userId && userId is doc.ownerId