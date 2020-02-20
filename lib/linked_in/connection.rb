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

      # Uncomment this for spammy logs - this is sometimes helpful to debug requests
      # logger = Logger.new $stderr
      # logger.level = Logger::DEBUG
      # self.response :logger, logger

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
      # When retrieving UGC posts - the urn must be encoded, but not the enclosing List - ex: "List({encoded_urn})"
      # Currently this only properly handles a single URN ... the LinkedIn API only supports a single URN in the List
      # If LinkedIn changes this, we will need to modify this to handle multiple URNs

      # Don't encode a List of bulk people ids - see Profile#people
      return arg if arg.starts_with?("List((id:")

      if arg.starts_with?("List(")
        org = arg.split('(')[1].split(')')[0]
        org = CGI::escape(org)
        arg = "List(#{org})"
      end

      # Encode any raw URNs as required with Protocol v2 - v1 calls still work with encoded URNs, so this is backwards compatible
      if arg.starts_with?('urn:li')
        arg = CGI::escape(arg)
      end
      arg
    end
  end
end
