#TogglClientSide =
#  startTimer: (task, cb) ->
#    Meteor.call 'toggl/startTimer', task, (timeEntry)->
#      console.log timeEntry
#    , (err, res)->
#      if cb and typeof cb == 'function'
#        console.log 'package start timer'
#        cb.apply @, [err, res]
#  stopTimer: (cb)->
#    Meteor.call 'toggl/stopTimer', (timeEntry)->
#      console.log timeEntry
#    , (err, res)->
#      if cb and typeof cb == 'function'
#        console.log 'package stop timer'
#        cb.apply @, [err, res]