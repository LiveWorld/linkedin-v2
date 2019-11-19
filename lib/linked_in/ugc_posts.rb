module LinkedIn

  class UGCPosts < APIResource

    # UGCPosts requires Protocol v2
    def ugc_posts(options = {})
      urn = options.delete(:urn)
      path = "/ugcPosts?q=authors&authors=List(#{CGI::escape(urn)})"
      LinkedIn::APICollection.new(get(path, options), @connection)
    end

    def delete_ugc_post(options = {})
      urn = CGI.escape options.delete(:urn)
      path = "/ugcPosts/#{urn}"
      delete(path)
    end
  end
end
