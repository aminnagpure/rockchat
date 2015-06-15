lineSep = '---------------------------'

Meteor.startup ->
	if not Meteor.users.findOne()?
		console.log lineSep.red
		console.log 'Inserting user admin'.red
		console.log 'email: admin@admin.com | password: admin'.red

		id = Meteor.users.insert
			createdAt: new Date
			emails: [
				address: 'admin@admin.com'
				verified: true
			],
			name: 'Admin'
			avatarOrigin: 'none'

		Accounts.setPassword id, 'admin'
