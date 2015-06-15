Template.loginForm.helpers
	userName: ->
		return Meteor.user()?.username

	showName: ->
		return 'hidden' unless Template.instance().state.get() is 'register'

	showPassword: ->
		return 'hidden' unless Template.instance().state.get() in ['login', 'register']

	showConfirmPassword: ->
		return 'hidden' unless Template.instance().state.get() is 'register'

	showEmailOrUsername: ->
		return 'hidden' unless Template.instance().state.get() is 'login'

	showEmail: ->
		return 'hidden' unless Template.instance().state.get() in ['register', 'forgot-password', 'email-verification']

	showRegisterLink: ->
		return 'hidden' unless Template.instance().state.get() is 'login'

	showForgotPasswordLink: ->
		return 'hidden' unless Template.instance().state.get() is 'login'

	showBackToLoginLink: ->
		return 'hidden' unless Template.instance().state.get() in ['register', 'forgot-password', 'email-verification']

	btnLoginSave: ->
		switch Template.instance().state.get()
			when 'register'
				return t('general.Submit')
			when 'login'
				return t('general.Login')
			when 'email-verification'
				return t('general.Send_confirmation_email')
			when 'forgot-password'
				return t('general.Reset_password')

Template.loginForm.events
	'submit #login-card': (event, instance) ->
		event.preventDefault()

		button = $(event.target).find('button.login')
		RocketChat.Button.loading(button)

		formData = instance.validate()
		if formData
			if instance.state.get() is 'email-verification'
				Meteor.call 'sendConfirmationEmail', formData.email, (err, result) ->
					RocketChat.Button.reset(button)
					toastr.success t('login.We_have_sent_registration_email')
					instance.state.set 'login'
				return

			if instance.state.get() is 'forgot-password'
				Meteor.call 'sendForgotPasswordEmail', formData.email, (err, result) ->
					RocketChat.Button.reset(button)
					toastr.success t('login.We_have_sent_password_email')
					instance.state.set 'login'
				return

			if instance.state.get() is 'register'
				Meteor.call 'registerUser', formData, (err, result) ->
					RocketChat.Button.reset(button)
					Meteor.loginWithPassword formData.email, formData.pass, (error) ->
						if error?.error is 'no-valid-email'
							toastr.success t('login.We_have_sent_registration_email')
							instance.state.set 'login'
						else
							Router.go 'index'
			else
				Meteor.loginWithPassword formData.emailOrUsername, formData.pass, (error) ->
					RocketChat.Button.reset(button)
					if error?
						if error.error is 'no-valid-email'
							instance.state.set 'email-verification'
						else
							toastr.error error.reason
						return
					Router.go 'index'

	'click .register': ->
		Template.instance().state.set 'register'

	'click .back-to-login': ->
		Template.instance().state.set 'login'

	'click .forgot-password': ->
		Template.instance().state.set 'forgot-password'

Template.loginForm.onCreated ->
	instance = @
	@state = new ReactiveVar('login')
	@validate = ->
		formData = $("#login-card").serializeArray()
		formObj = {}
		validationObj = {}

		for field in formData
			formObj[field.name] = field.value

		if instance.state.get() isnt 'login'
			unless formObj['email'] and /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+\b/i.test(formObj['email'])
				validationObj['email'] = t('login.Invalid_email')

		if instance.state.get() isnt 'forgot-password'
			unless formObj['pass']
				validationObj['pass'] = t('login.Invalid_pass')

		if instance.state.get() is 'register'
			unless formObj['name']
				validationObj['name'] = t('login.Invalid_name')
			if formObj['confirm-pass'] isnt formObj['pass']
				validationObj['confirm-pass'] = t('login.Invalid_confirm_pass')

		$("#login-card input").removeClass "error"
		unless _.isEmpty validationObj
			button = $('#login-card').find('button.login')
			RocketChat.Button.reset(button)
			$("#login-card h2").addClass "error"
			for key of validationObj
				$("#login-card input[name=#{key}]").addClass "error"
			return false

		$("#login-card h2").removeClass "error"
		$("#login-card input.error").removeClass "error"
		return formObj

Template.loginForm.onRendered ->
	Tracker.autorun =>
		switch this.state.get()
			when 'login', 'forgot-password', 'email-verification'
				Meteor.defer ->
					$('input[name=email]').select().focus()

			when 'register'
				Meteor.defer ->
					$('input[name=name]').select().focus()
