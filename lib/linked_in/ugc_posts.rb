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

    def delete_ugc_post(options = {})
      urn = CGI.escape options.delete(:urn)
      path = "/ugcPosts/#{urn}"
      delete(path)
    end

  end
end
