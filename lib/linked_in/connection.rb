module LinkedIn
  # Used to perform requests against LinkedIn's API.
  class Connection < ::Faraday::Connection

    def initialize(url=nil, options=nil, &block)

      if url.is_a? Hash
        options = url
        url = options[:url]
      end

      url = default_url if url.nil?

      super url, options, &block

      # We need to use the FlatParamsEncoder so we can pass multiple of
      # the same param to certain endpoints (like the search API).
      self.options.params_encoder = ::Faraday::FlatParamsEncoder

      logger = Logger.new $stderr
      logger.level = Logger::DEBUG
      self.response :logger, logger

      self.response :linkedin_raise_error
    end


    private ##############################################################


    def default_url
      LinkedIn.config.api + LinkedIn.config.api_version
    end
  end
end

module Faraday
  module FlatParamsEncoder
    def self.escape(arg)
      ap arg
      # When retrieving UGC posts - the urn must be encoded, but not the enclosing List - ex: "List({encoded_urn})"
      # Currently this only properly handles a single URN ... will need to be modified to handle multiple URNs if needed
      if arg.starts_with?("List(")
        org = arg.split('(')[1].split(')')[0]
        org = CGI::escape(org)
        arg = "List(#{org})"
      end
      arg
    end
  end
end