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
  #  http://123.123.123.123:3124/database/collection/query

  class Mongo < Base
		@@id_key = '_id'
    #
    #
    def initialize *category_names, options
      check_gem
	
			unless options.try(:[], :url) && options.try(:[], :db)
				raise_no_db_given(category_names)
			end
		
		  @db = RestClient::Resource.new options.delete(:url), options
			@database = options.delete(:db)
	
		  @key_format  = key_format && key_format.to_sym || :to_sym
		end

		def initialize
			@key_format = :to_sym
		end

    # Tries to require the rest_client gem.
    #
    def check_gem # :nodoc:
      require 'rest_client'
    rescue LoadError
      warn_gem_missing 'rest-client', 'the MongoDB source'
      exit 1
    end


		def harvest category
			collection = category.from.to_s || category.index_name.to_s
			resp = @db["/#{@database}/#{category.index_name.to_s}/?@limit=0"].get
			JSON.parse(resp)['rows'].each do |row|
				index_key = row.fetch(@@id_key).values
				row.delete(@@id_key)
				text = row[collection].to_s
				next unless text
				yield index_key, text
			end
		end

    def raise_no_db_given category_names # :nodoc:
      raise NoMongoDBGiven.new(category_names.join(', '))
    end
  end
end
