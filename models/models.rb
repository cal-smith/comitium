class Categories < DB
	#methods we need
	# add
	# delete
	# edit
	#
	#
	#

	def self.all
		return @@db.exec("SELECT * FROM categories")
	end

	def self.posts category, offset
		return @@db.exec("SELECT * FROM (select * from posts WHERE category = $1 LIMIT 25 OFFSET $2) posts
						LEFT OUTER JOIN users on posts.userid = users.userid", [category, offset])
	end

	def self.info category
		return @@db.exec("SELECT * FROM categories WHERE name = $1", [category])
	end
end

class Posts < DB
	#methods we need
	# move
	# delete
	# 
	#
	#
	#
	#

	def self.op post, category
		return @@db.exec("SELECT postid, category, posts.userid, title, body, username FROM posts, users
						WHERE posts.userid = users.userid
						AND posts.postid = $1 AND posts.category = $2 
						ORDER BY posted ASC LIMIT 25", [post, category])
	end

	def self.replies post, offset
		return @@db.exec("SELECT postid, replies.userid, body, username FROM replies, users
							WHERE replies.userid = users.userid
							AND postid = $1 
							ORDER BY posted ASC 
							LIMIT 25 OFFSET $2", [post, offset])
	end

	def self.add category, userid, title, md, html
		postid = "t1_" << SecureRandom.uuid
		posted = DateTime.now.to_s
		begin
			@@db.exec("INSERT INTO posts (postid, category, userid, title, md, html, posted)
							VALUES ($1, $2, $3, $4, $5, $6, $7)", [postid, category, userid, title, md, html, posted])
		rescue Exception => e
			puts e
			return "error"
		end
		return true
	end

	def self.reply userid, postid, md, html
		replyid = "t2_" << SecureRandom.uuid
		posted = DateTime.now.to_s
		begin
			@@db.exec("INSERT INTO replies (postid, replyid, userid, md, html, posted)
							VALUES ($1, $2, $3, $4, $5, $6)", [postid, replyid, userid, md, html, posted])
		rescue Exception => e
			puts e
			return "error"
		end
		return true
	end
end

class User < DB
	def self.check user, password=nil
		if !password
			return @@db.exec("SELECT * FROM users WHERE users.username = $1 ", [user])
		else 
			return @@db.exec("SELECT * FROM users WHERE 
						users.username = $1 
						AND users.password = $2", [user, password])
		end
	end

	def self.add user, password

	end
end