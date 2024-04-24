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

      # Uncomment these for spammy logs - this is sometimes helpful to debug requests
      # logger = Logger.new $stderr
      # logger.level = Logger::DEBUG
      # self.response :logger, logger, body: true, bodies: { request: true, response: true }
      # End logging

      self.response :linkedin_raise_error
    end


    private ##############################################################


    def default_url
      LinkedIn.config.api
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
      # don't encode the commas in the actions arg for #webhook_notifications
      # List(COMMENT,ADMIN_COMMENT,COMMENT_DELETE)
      return arg if arg.include?('COMMENT') || arg.include?('ADMIN_COMMENT')

      if arg.starts_with?("List(")
        # organization
        # this might have changed to only pass in the id, not the urn?
        if arg.include?('organization')
          org = arg.split('(')[1].split(')')[0]
          org = CGI::escape(org)
          arg = "List(#{org})"
        elsif arg.include?('image')
          # starting with: List(urn:li:image:C4E03AQGLvLIOvFlF6Q,urn:li:image:C4E03AQF-AtRltaJRVw)
          # we want to return: List(urn%3Ali%3Aimage%3AC4E03AQGLvLIOvFlF6Q,urn%3Ali%3Aimage%3AC4E03AQF-AtRltaJRVw)
          # extract the list of media ids
          raw_media = arg.split('(')[1].split(')')[0]
          media_list = raw_media.split(',')
          # escape each media urn individually
          media_list = media_list.collect{ |media| CGI::escape(media) }
          # put the list of escaped media urns back together
          escaped_media = media_list.join(",")
          arg = "List(#{escaped_media})"
        end
      end

      # Encode any raw URNs as required with Protocol v2 - v1 calls still work with encoded URNs, so this is backwards compatible
      if arg.starts_with?('urn:li')
        arg = CGI::escape(arg)
      end
      arg
    end
  end
end
