module LinkedIn

  class UGCPosts < APIResource

    # UGCPosts requires Protocol v2
    def ugc_posts(options = {})
      urn = options.delete(:urn)
      path = "/ugcPosts?q=authors&authors=List(#{urn})"
      LinkedIn::APICollection.new(get(path, options), @connection)
    end

    def ugc_post(options = {})
      urn = options.delete(:urn)
      path = "/ugcPosts/#{CGI::escape(urn)}?viewContext=AUTHOR"
      get(path, options)
    end

    # New Posts API: https://learn.microsoft.com/en-us/linkedin/marketing/integrations/community-management/shares/posts-api?view=li-lms-2023-01&tabs=http#delete-posts
    def delete_ugc_post(options = {})
      urn = CGI.escape options.delete(:urn)
      path = "/posts/#{urn}"
      delete(path, nil, nil)
    end

  end
end
