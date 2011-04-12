module Sources

  # Raised when a Couch source is instantiated without a file.
  #
  # Example:
  #   Sources::Couch.new(:column1, :column2) # without file option
  #
  class NoMongoDBGiven < StandardError; end

  # A Couch database source.
  #
  # Options:
  # * url
  # and all the options of a <tt>RestClient::Resource</tt>.
  # See http://github.com/archiloque/rest-client.
  #
  # Examples:
  #  Sources::Couch.new(:title, :author, :isbn, url:'localhost:5984')
  #  Sources::Couch.new(:title, :author, :isbn, url:'localhost:5984', user:'someuser', password:'somepassword')

  #  Sources::Mongo.new(:collection => "", :limit => 10 , url:'',user:'', passowrd:'') 
  #  Sources::Mongo.new(:collection => "", :db => "somedb", :query => { a => 10 }, :limit => 10, url: '', )
  #  http://123.123.123.123:3124/database/collection/query
  class Mongo < Base

    #
    #
    def initialize *category_names, options
      check_gem

      Hash === options && options[:url] || raise_no_db_given(category_names)

      @db = RestClient::Resource.new options.delete(:url), options
			@database = options.delete(:db)
			
      @key_format  = key_format && key_format.to_sym || :to_sym
    end

    # Tries to require the rest_client gem.
    #
    def check_gem # :nodoc:
      require 'rest_client'
    rescue LoadError
      warn_gem_missing 'rest-client', 'the MongoDB source'
      exit 1
    end


		def harvest type, category
			category_name = category.to_s
			resp = @db["/#{@database}/#{category_name}/?@limit=0"].get
			JSON.parse(resp)['rows'].each do |row|
				index_key = row.fetch(@@id_key).values
				row.delete(@@id_key)
				text = row
				next unless text
				yield index_key, text
			end
		end

    def raise_no_db_given category_names # :nodoc:
      raise NoMongoDBGiven.new(category_names.join(', '))
    end
  end
end
