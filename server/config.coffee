if not ServiceConfiguration.configurations.findOne(service: "google")
	ServiceConfiguration.configurations.insert
		service: 'google'
		clientId: '452535105296-59bu8jeugo1mgoibumsutqth0vfhbmc9.apps.googleusercontent.com'
		secret: 'r3Lje0q1W9TFtzfqYDhOoESn'
		loginStyle: 'popup'