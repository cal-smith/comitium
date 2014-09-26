class Forum < Sinatra::Application
	get '/admin/?' do #root admin page. status style. how many users, posts, other random junk
		'admin things. essentially a thin interface over the DB structure'
	end

	post '/admin/create/category/?' do #create category
		':name/:description/ in url vars'
		name = URI.decode(params[:name]).downcase
		description = URI.decode(params[:description])
		#add admin only validation...tokens?
		db.exec("INSERT INTO categories (name, description) VALUES ($1, $2)", [name, description])
	end
end