module LinkedIn

  # The new Posts API
  class Posts < APIResource

    def posts(options = {})
      urn = options.delete(:urn)
      path = "/posts?author=#{urn}&q=author"
      LinkedIn::APICollection.new(get(path, options), @connection)
    end

    def post_by_urn(options = {})
      urn = options.delete(:urn)
      path = "/posts/#{CGI::escape(urn)}?viewContext=AUTHOR"
      get(path, options)
    end

    def image_by_urn(options = {})
      urn = options.delete(:urn)
      path = "/images/#{CGI::escape(urn)}"
      get(path, options)
    end

    def video_by_urn(options = {})
      urn = options.delete(:urn)
      path = "/videos/#{CGI::escape(urn)}"
      get(path, options)
    end

    def document_by_urn(options = {})
      urn = options.delete(:urn)
      path = "/documents/#{CGI::escape(urn)}"
      get(path, options)
    end

  end
end
