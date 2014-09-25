require 'pg'
require 'sinatra'
require 'bcrypt'
require 'redcarpet'
require 'uri'
require 'securerandom'


#split things up a bit, move admin stuff to /admin, category stuff to /category, etc?

if ENV['OPENSHIFT_POSTGRESQL_DB_HOST']
	db = PGconn.connect(ENV['OPENSHIFT_POSTGRESQL_DB_HOST'], ENV['OPENSHIFT_POSTGRESQL_DB_PORT'], "", "", "forum")	
else
	db = PGconn.connect("localhost", "5432", "", "", "forum")
end

db.exec("CREATE TABLE IF NOT EXISTS posts(
		postid TEXT NOT NULL,
		category TEXT NOT NULL,
		userid TEXT NOT NULL,
		title TEXT NOT NULL,
		md TEXT NOT NULL,
		html TEXT NOT NULL,
		posted DATE NOT NULL
	)")

db.exec("CREATE TABLE IF NOT EXISTS replies(
		postid TEXT NOT NULL,
		replyid TEXT NOT NULL,
		userid TEXT NOT NULL,
		md TEXT NOT NULL,
		html TEXT NOT NULL,
		posted DATE NOT NULL
	)")

db.exec("CREATE TABLE IF NOT EXISTS categories(
		name TEXT NOT NULL,
		description TEXT
	)")

db.exec("CREATE TABLE IF NOT EXISTS users(
		userid TEXT NOT NULL,
		username TEXT NOT NULL,
		password TEXT NOT NULL,
		created DATE,
		ups BIGINT,
		downs BIGINT,
		mode INT
	)")

db.exec("CREATE TABLE IF NOT EXISTS settings(
		setting TEXT,
		value TEXT
	)")

#three user levels: user, mod, admin. no more no less.
#markdown for commenting. <3 markdown
#super simple html structure
#essentially let people drop w/e .css file over top the html
#simplicity and speed over all else
#SELECT * FROM (select * from posts where postid = '1') post 
#LEFT OUTER JOIN users on post.userid = users.userid

#UNION 

#SELECT * FROM (select * from replies where postid = '1') reply 
#LEFT OUTER JOIN users on reply.userid = users.userid
post '/:category/?' do #submit a new post to category.
	postid = "t1_" << SecureRandom.uuid
	category = params[:category]
	userid
	title = URI.decode(params[:title])
	md = URI.decode(params[:md])
	html = #parse md to html
	posted = DateTime.now.to_s
	db.exec("INSERT INTO posts (postid, category, userid, title, md, html, posted)
	VALUES ($1, $2, $3, $4, $5, $6, $7)",
	[postid, category, userid, title, md, html, posted])
	'{"status": "success"}'
end

post '/:category/:post/?' do #reply to a post. takes the post to reply to and the response body
	#?user=id&body=body+text
	'submit a reply'
	postid = params[:post] #if postid !! exist return fail
	replyid = "t2_" << SecureRandom.uuid
	md = URI.decode(params[:md])
	posted = DateTime.now.to_s
end

post '/edit/:id' do
	#if replyid => update reply
	#if postid => update post
end

post '/vote/?' do

end

get '/register/?' do #display the registration form
	'registration'
end

post '/register/:user/:pass/?' do #takes a username and password. bcrypts the password, gives the user an id, sticks it in the db
	'register user'
end

get '/login/?' do #display the login form
	'login'
end

post '/login/:user/:pass/?' do #logs the user in, initiates its session etc
	'login user'
end

get '/admin/?' do #root admin page. status style. how many users, posts, other random junk
	'admin things. essentially a thin interface over the DB structure'
end

post '/admin/create/category/:name/:description/?' do #create category
	name = URI.decode(params[:name]).downcase
	description = URI.decode(params[:description])
	#add admin only validation...tokens?
	db.exec("INSERT INTO categories (name, description) VALUES ($1, $2)", [name, description])
end

get '/' do #list forum categories
	#db.get(SELECT * FROM category)
	categories = db.exec("SELECT * FROM categories")
	erb :index, :locals => {:listing => categories.values(), :category => nil}#move to single page "app" designe
end

get '/:category/?' do #list posts in a category. category is a urlsafe name
	pass unless params[:page].nil? or params[:page].to_i.to_s == params[:page].to_s
	#check for negative page
	page = 1
	if params[:page]
		page = page
	end
	page = page - 1
	offset = 25 * page #page starts at 1, by subtracting 1 from page and multiplying by 25 we get the correct offset

	posts = db.exec("SELECT * FROM (select * from posts WHERE category = $1 LIMIT 25 OFFSET $2) posts
					LEFT OUTER JOIN users on posts.userid = users.userid", [params[:category], offset])

	category = db.exec("SELECT * FROM categories WHERE name = $1", [params[:category]])
	
	category = category.values()
	erb :category, :locals => {:listing => posts.values(), :category => category[0][0], :about => category[0][1]}
end

get '/:category/:post/?:page?/?' do #contents post in a category with optional page param. post is just a uniqe hash
	#check for negative page
	page = 1
	if params[:page]
		page = page
	end
	page = page - 1
	offset = 25 * page #page starts at 1, by subtracting 1 from page and multiplying by 25 we get the correct offset

	op = db.exec("SELECT postid, category, posts.userid, title, body, username FROM posts, users
				  WHERE posts.userid = users.userid
				  AND posts.postid = $1 AND posts.category = $2 
				  ORDER BY posted ASC LIMIT 25", [params[:post], params[:category]])

	replies = db.exec("SELECT postid, replies.userid, body, username FROM replies, users
					   WHERE replies.userid = users.userid
					   AND postid = $1 
					   ORDER BY posted ASC 
					   LIMIT 25 OFFSET $2", [params[:post], offset])

	erb :post, :locals => {:op => op.values(), :listing => replies.values(), :category => params[:category]}
end





