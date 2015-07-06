if Meteor.isServer
  Meteor.users.after.insert (userId, doc) ->
    Boards.insert
      ownerId: doc._id
      title: 'Backlog'
      order: 1
      isBacklog: true
      config:
        bgColor: 15
        showArchieved: 0
        sortByPriority: 0
    , (err, res) ->
      err and console.log err