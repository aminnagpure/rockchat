Meteor.methods
	setUsername: (username) ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] setUsername -> Invalid user")

		console.log '[methods] setUsername -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

		user = Meteor.user()

		if user.username?
			throw new Meteor.Error 'username-already-setted'

		if not usernameIsAvaliable username
			throw new Meteor.Error 'username-unavaliable'

		if not /^[0-9a-z-_.]+$/.test username
			throw new Meteor.Error 'username-invalid'

		if not user.username?
			# put user in general channel
			ChatRoom.update '57om6EQCcFami9wuT',
				$push:
					usernames:
						$each: [username]
						$sort: 1

			if not ChatSubscription.findOne(rid: '57om6EQCcFami9wuT', 'u._id': user._id)?
				ChatSubscription.insert
					rid: '57om6EQCcFami9wuT'
					name: 'general'
					ts: new Date()
					t: 'c'
					f: true
					open: true
					alert: true
					unread: 1
					u:
						_id: user._id
						username: username

				ChatMessage.insert
					rid: '57om6EQCcFami9wuT'
					ts: new Date()
					t: 'wm'
					msg: username
					u:
						_id: user._id
						username: username

		Meteor.users.update({_id: user._id}, {$set: {username: username}})

		return username

slug = (text) ->
	text = slugify text, '.'
	return text.replace(/[^0-9a-z-_.]/g, '')

usernameIsAvaliable = (username) ->
	if username.length < 1
		return false

	return not Meteor.users.findOne({username: username})?
