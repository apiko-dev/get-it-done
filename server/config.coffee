if not ServiceConfiguration.configurations.findOne(service: "google")
  ServiceConfiguration.configurations.insert
    service: 'google'
    clientId: '452535105296-59bu8jeugo1mgoibumsutqth0vfhbmc9.apps.googleusercontent.com'
    secret: 'r3Lje0q1W9TFtzfqYDhOoESn'
    loginStyle: 'popup'
    forceApprovalPrompt: true

MailConfig =
  hostName: 'smtp.mailgun.org',
  password: '9108b2145fd152617199a7f7c5e962bc',
  username: 'smtp://postmaster@sandbox7cafe82fec034c58b6c626f1b4c2a1e8.mailgun.org',
  port: 587

process.env.MAIL_URL = MailConfig.username + ':' + MailConfig.password + '@' + MailConfig.hostName + ':' + MailConfig.port;