class Forum < Sinatra::Application
	get '/login/?' do #display the login form
		erb :login, :locals => {
			:category => nil}
	end

	post '/login/?' do #logs the user in, initiates its session etc
		#check if user exists
			#if password mismatch
				# => "Incorrect password"
			#else
				# => set session
		#else
		# => suggest they register
		user = User.check(user, password)
		if user[0]
			if user[0][2] #User.password(password)?
				session[:user] = user[0][1]
				session[:uid] = user[0][0]
				#date created is at [0][3]
				redirect to '/'
			end
		else
			"Ethier that account doesnt exist, or you got the password wrong. Try again?"
		end
	end

	post '/register/?' do #takes a username and password. bcrypts the password, gives the user an id, sticks it in the db
		#check if user doesnt exist
			#ensure username, password, and email are filled in
			#add user
		#else
			#offer to login
		#the key thing is that we dont register the same user twice, and we keep passwords nicely secure, 
		#outside of that email's are really just a thing so we can bug them, so someone can totally register multiple times
		#with the same email, why stop them?
		unless User.check(user)
			#ensure username, password, and email are things
			User.add(user, password, email)
		else
			"login?"
		end
	end
end