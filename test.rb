class Test
	def initialize(a="World")
		@world = a
	end
	def self.hi
		return "hi!"
	end

	def yo(person)
		return "yo, #{person}"
	end

	def hello
		return "Hello, #{@world}"
	end
end