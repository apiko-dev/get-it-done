@Emails = new Mongo.Collection 'emails' 

Emails.allow
  insert: (userId, doc) ->
    console.log 'not Emails.findOne email: doc.email', not Emails.findOne email: doc.email
    doc.email and	validateEmail doc.email

if Meteor.isServer
  Emails.after.insert (userId, doc) ->
    Email.send
      to: doc.email
      from: 'getitdone@jssolutionsdev.com'
      subject: 'Subscription'
      text: 'You successfully subscripted to updates. Get it Done'

validateEmail = (email) ->
  re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
  re.test email