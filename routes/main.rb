class Forum < Sinatra::Application
	get '/' do #list forum categories
		erb :index, :locals => {
			:listing => Categories.all.values(), 
			:category => nil}
	end

	get '/:category/?' do #list posts in a category. category is a urlsafe name
		pass unless params[:page].nil? or params[:page].to_i.to_s == params[:page].to_s
		if params[:page]
			offset = page params[:page]
		else
			offset = page
		end

		category = Categories.info params[:category]
		category = category.values()

		erb :category, :locals => {
			:listing => Categories.posts(params[:category], offset).values(), 
			:category => category[0][0], 
			:about => category[0][1]}
	end

	get '/:category/:post/?:page?/?' do #contents post in a category with optional page param. post is just a uniqe hash
		if params[:page]
			offset = page params[:page]
		else
			offset = page
		end
		erb :post, :locals => {
			:op => Posts.op(params[:post], params[:category]).values(), 
			:listing => Posts.replies(params[:post], offset).values(), 
			:category => params[:category]}
	end

	post '/:category/?' do #submit a new post to category.
		title = URI.decode(params[:title])
		category = params[:category]
		userid = session[:uid]
		md = URI.decode(params[:md])
		html = #parse md to html
		Posts.add category, userid, title, md, html
		#if no errors, and not rate-limited
		#redirect to the new post
		'{"status": "success"}'
		#else
		#'{"status": "try again in a few moments"}'
	end

	post '/:category/:post/?' do #reply to a post. takes the post to reply to and the response body
		userid = session[:uid]
		postid = params[:post]
		md = URI.decode(params[:md])
		html  =
		Posts.reply userid, postid, md, html
		'{"status": "success"}'
		#return success so the the js on page knows everything is okay
		#but of course, db issues are unlikely, so insert the reply beforhand
	end

	post '/edit/:id' do
		if params[:id][0..1] == "t1"
			#post
		elsif params[:id][0..1] == "t2"
			#reply
		end
		Posts.edit id, md, html
		#if replyid => update reply
		#if postid => update post
	end

	post '/vote/?' do

	end
end