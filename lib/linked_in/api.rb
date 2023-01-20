module LinkedIn
  class API

    attr_accessor :access_token

    def initialize(access_token=nil)
      access_token = parse_access_token(access_token)
      verify_access_token!(access_token)
      @access_token = access_token

      # https://docs.microsoft.com/en-us/linkedin/shared/api-guide/concepts/protocol-version
      # Protocol version 1.0.0
      @connection = LinkedIn::Connection.new params: default_params, headers: default_headers do |conn|
        conn.request :multipart
      end
      @connection.adapter Faraday.default_adapter

      # Protocol version 2.0.0
      # Calls will eventually need to be migrated to v2.0 as v1 is apparently going to be deprecated soon
      # UGCPosts use v2 exclusively - this requires certain params to be URL encoded (URNS especially) ... check the docs, it gets tricky...
      @connection_v2 = LinkedIn::Connection.new params: default_params, headers: protocol_v2_headers do |conn|
        conn.request :multipart
      end
      @connection_v2.adapter Faraday.default_adapter

      initialize_endpoints
    end

    extend Forwardable # Composition over inheritance

    # I do not have access to the jobs related endpoints.
    # def_delegators :@jobs, :job,
    #                        :job_bookmarks,
    #                        :job_suggestions,
    #                        :add_job_bookmark

    # these appear to be old v1 endpoints
    def_delegators :@people, :profile,
                             :skills,
                             :connections,
                             :picture_urls,
                             :new_connections

    def_delegators :@search, :search

    # Not part of v2??
    # def_delegators :@groups, :join_group,
    #                          :group_posts,
    #                          :group_profile,
    #                          :add_group_share,
    #                          :group_suggestions,
    #                          :group_memberships,
    #                          :post_group_discussion

    def_delegators :@organizations, :organization,
                                    :brand,
                                    :organization_acls,
                                    :organization_search,
                                    :organization_page_statistics,
                                    :organization_follower_statistics,
                                    :organization_share_statistics,
                                    :organization_follower_count

    def_delegators :@communications, :send_message

    def_delegators :@share_and_social_stream, :shares,
                                              :share,
                                              :likes,
                                              :like,
                                              :unlike,
                                              :comments,
                                              :comment,
                                              :get_share,
                                              :get_social_actions,
                                              :delete_comment,
                                              :migrate_update_keys

    def_delegators :@media, :summary,
                            :upload

    def_delegators :@ugc_posts, :ugc_posts,
                                :delete_ugc_post,
                                :ugc_post


    def_delegators :@ads, :ad_direct_sponsored_contents

    # V2 API Profile API - requires Protocol v2 headers
    def_delegators :@profile, :people

    def_delegators :@webhooks, :subscribe_to_webhooks,
                               :webhook_notifications


    private ##############################################################

    def initialize_endpoints
      @jobs = LinkedIn::Jobs.new(@connection)
      @people = LinkedIn::People.new(@connection)
      @search = LinkedIn::Search.new(@connection)
      @organizations = LinkedIn::Organizations.new(@connection)
      @communications = LinkedIn::Communications.new(@connection)
      @share_and_social_stream = LinkedIn::ShareAndSocialStream.new(@connection)
      @media = LinkedIn::Media.new(@connection)
      # UGCPosts requires Protocol v2
      @ugc_posts = LinkedIn::UGCPosts.new(@connection_v2)
      @ads = LinkedIn::Ads.new(@connection_v2)
      @profile = LinkedIn::Profile.new(@connection_v2)
      @webhooks = LinkedIn::Webhooks.new(@connection_v2)
      # @groups = LinkedIn::Groups.new(@connection) not supported by v2 API?
    end

    def default_params
      # LIv2 TODO - Probably can just remove?
      # https//developer.linkedin.com/documents/authentication
      #return { oauth2_access_token: @access_token.token }
      {}
    end

    def default_headers
      # https://developer.linkedin.com/documents/api-requests-json
      {
        "Linkedin-Version" => LinkedIn.config.api_version,
        "x-li-format" => "json",
        "Authorization" => "Bearer #{@access_token.token}",
        "Content-Type" => "application/json"
      }
    end

    def protocol_v2_headers
      default_headers.merge({ "X-RestLi-Protocol-Version" => "2.0.0" })
    end

    def verify_access_token!(access_token)
      if not access_token.is_a? LinkedIn::AccessToken
        raise no_access_token_error
      end
    end

    def parse_access_token(access_token)
      if access_token.is_a? LinkedIn::AccessToken
        return access_token
      elsif access_token.is_a? String
        return LinkedIn::AccessToken.new(access_token)
      end
    end

    def no_access_token_error
      msg = LinkedIn::ErrorMessages.no_access_token
      LinkedIn::InvalidRequest.new(msg)
    end
  end
end
