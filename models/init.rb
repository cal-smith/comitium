require 'pg'
require 'bcrypt'

class DB
	@@lol = "lol"
	def self.init
		if ENV['OPENSHIFT_POSTGRESQL_DB_HOST']
			@@db = PGconn.connect(ENV['OPENSHIFT_POSTGRESQL_DB_HOST'], ENV['OPENSHIFT_POSTGRESQL_DB_PORT'], "", "", "forum")	
		else
			@@db = PGconn.connect("localhost", "5432", "", "", "forum")
		end

		@@db.exec("CREATE TABLE IF NOT EXISTS posts(
				postid TEXT NOT NULL,
				category TEXT NOT NULL,
				userid TEXT NOT NULL,
				title TEXT NOT NULL,
				md TEXT NOT NULL,
				html TEXT NOT NULL,
				posted DATE NOT NULL
			)")

		@@db.exec("CREATE TABLE IF NOT EXISTS replies(
				postid TEXT NOT NULL,
				replyid TEXT NOT NULL,
				userid TEXT NOT NULL,
				md TEXT NOT NULL,
				html TEXT NOT NULL,
				posted DATE NOT NULL
			)")

		@@db.exec("CREATE TABLE IF NOT EXISTS categories(
				name TEXT NOT NULL,
				description TEXT
			)")

		@@db.exec("CREATE TABLE IF NOT EXISTS users(
				userid TEXT NOT NULL,
				username TEXT NOT NULL,
				password TEXT NOT NULL,
				created DATE,
				ups BIGINT,
				downs BIGINT,
				mode INT
			)")

		@@db.exec("CREATE TABLE IF NOT EXISTS settings(
				setting TEXT,
				value TEXT
			)")
	end
end

DB.init

require_relative 'models'

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