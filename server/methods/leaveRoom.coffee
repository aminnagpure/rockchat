Meteor.methods
	leaveRoom: (rid) ->
		fromId = Meteor.userId()
		# console.log '[methods] leaveRoom -> '.green, 'fromId:', fromId, 'rid:', rid

		unless Meteor.userId()?
			throw new Meteor.Error 300, 'Usuário não logado'

		room = ChatRoom.findOne rid

		update =
			$pull:
				usernames: Meteor.user().username

		ChatSubscription.update { rid: rid },
			$set:
				name: room.name
		,
			multi: true

		if room.t isnt 'c' and room.usernames.indexOf(Meteor.user().username) isnt -1
			removedUser = Meteor.user()

			ChatMessage.insert
				rid: rid
				ts: (new Date)
				t: 'ul'
				msg: removedUser.name
				u:
					_id: removedUser._id
					username: removedUser.username

		if room.u._id is Meteor.userId()
			newOwner = _.without(room.usernames, Meteor.user().username)[0]
			if newOwner?
				newOwner = Meteor.users.findOne username: newOwner

				if newOwner?
					if not update.$set?
						update.$set = {}

					update.$set['u._id'] = newOwner._id
					update.$set['u.username'] = newOwner.username

		ChatSubscription.remove { rid: rid, 'u._id': Meteor.userId() }

		ChatRoom.update rid, update
