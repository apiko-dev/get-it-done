if not ServiceConfiguration.configurations.findOne(service: "google")
	ServiceConfiguration.configurations.insert
		service: 'google'
		clientId: '909470480368-2eck9vorrtl5me5k0fnlggu1uu786crf.apps.googleusercontent.com'
		secret: 'T2g9ZWnohhgDsFchQvwOIipb'
		loginStyle: 'popup'