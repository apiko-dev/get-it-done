if not ServiceConfiguration.configurations.findOne(service: "google")
  ServiceConfiguration.configurations.insert
    service: 'google'
    clientId: '********************************************************'
    secret: '****************************************************'
    loginStyle: 'popup'
    forceApprovalPrompt: true

MailConfig =
  hostName: 'smtp.mailgun.org'
  password: '*********************************'
  username: '*******************************************'
  port: 587

process.env.MAIL_URL = "MailConfig.username:MailConfig.password@MailConfig.hostName:MailConfig.port"
