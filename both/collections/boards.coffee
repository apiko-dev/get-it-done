@Boards = new Mongo.Collection 'boards'

Boards.allow
  insert: (userId, doc) ->
    userId && userId is doc.ownerId
  update: (userId, doc) ->
    userId && userId is doc.ownerId
  remove: (userId, doc) ->
    userId && userId is doc.ownerId

if Meteor.isClient
  Boards.before.insert (userId, doc) ->
    doc.config = doc.config or {}
    if not doc.config.bgColor?
      randomColorIndex = Math.floor(Math.random() * (COLORS.length))
      doc.config.bgColor = randomColorIndex # doc.config.bgColor or 14
    doc.config.sortByPriority = 0
    doc.config.showArchieved = 0
    maxOrderBoard = Boards.findOne {boardId: doc.boardId}, {sort: {order: -1}}
    maxOrder = if maxOrderBoard then maxOrderBoard.order else 0
    if not doc.insertInTheBeginning
      doc.order = maxOrder + 1
    else
      doc.order = doc.minBoardOrder - 0.001
      delete doc["minBoardOrder"]
      delete doc["insertInTheBeginning"]
    doc.completed = doc.completed or 0

if Meteor.isServer
  Boards.after.remove (userId, doc) ->
    Tasks.remove {boardId: doc._id}, (err, res) ->
      console.log err or res
    Chips.remove {boardId: doc._id}, (err, res) ->
      console.log err or res
