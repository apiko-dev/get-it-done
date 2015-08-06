@Emails = new Mongo.Collection 'emails'

Emails.allow
  insert: (userId, doc) ->
    doc.email and validateEmail(doc.email) and not Emails.findOne email: doc.email

if Meteor.isServer
  Emails.after.insert (userId, doc) ->
    Email.send
      to: doc.email
      from: 'getitdone@jssolutionsdev.com'
      subject: 'Subscription'
      html: emailBody

validateEmail = (email) ->
  re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
  re.test email

emailBody = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><!-- NAME: 1 COLUMN --><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head><body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" offset="0" style="margin: 0;padding: 0;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;background-color: white;height: 100% !important;width: 100% !important;"><center><table align="center" border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="bodyTable" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;margin: 0;padding: 0;background-color: white;height: 100% !important;width: 100% !important;"><tr><td align="center" valign="top" id="bodyCell" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;margin: 0;padding: 20px;border-top: 0;height: 100% !important;width: 100% !important;"><p style="text-align: center;"><span style="font-size: 25px;">You successfully subscripted to updates from <a style="color: #E25041;text-decoration: none" href="http://get-it-done.jssolutionsdev.com" title="Get it Done">Get it Done</a></span></p><p><br></p><p style="text-align: center;"><span style="font-size: 18px;">With ♡ from <a href="http://jssolutionsdev.com" rel="nofollow"><span style="color: #2969B0;">JSSolutions</span></a></span></p></td></tr></table></center></body></html>'