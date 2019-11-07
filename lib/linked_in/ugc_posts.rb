module LinkedIn

  class UGCPosts < APIResource

    # UGCPosts requires Protocol v2
    def ugc_posts(options = {})
      urn = options.delete(:urn)
      path = "/ugcPosts?q=authors&authors=List(#{CGI::escape(urn)})"
      LinkedIn::APICollection.new(get(path, options), @connection)
    end

  end

end