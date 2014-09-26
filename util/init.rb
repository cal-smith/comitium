#require_relative 'tools'
class Forum < Sinatra::Application
	#check for negative page, and simply return page 1
	def page p=1
		return 25 * (p - 1)
	end
	#pages starts at 1, by subtracting 1 from p and multiplying by 25 we get the correct offset
	
	def ratelimit
	end
end

