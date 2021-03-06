###
# Mentions is a named function that will process Mentions
# @param {Object} message - The message object
###

class MentionsServer
	constructor: (message) ->
		# If message starts with /me, replace it for text formatting
		mentions = []
		message.msg.replace /(?:^|\s|\n)(?:@)([A-Za-z0-9-_.]+)/g, (match, mention) ->
			mentions.push mention
		if mentions.length isnt 0
			mentions = _.unique mentions
			verifiedMentions = []
			mentions.forEach (mention) ->
				verifiedMention = Meteor.users.findOne({username: mention}, {fields: {_id: 1, username: 1}})
				verifiedMentions.push verifiedMention if verifiedMention?
			if verifiedMentions.length isnt 0
				message.mentions = verifiedMentions
		return message

RocketChat.callbacks.add 'beforeSaveMessage', MentionsServer