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
      path = "/posts/#{CGI::escape(urn)}"
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

    # POST https://api.linkedin.com/rest/posts
    def organic_post(options = {})

      actor = options.delete(:actor)
      commentary = options.delete(:message)
      image_urn = options.delete(:image_urn)

      body = {
        author: actor,
        commentary: commentary,
        visibility: "PUBLIC",
        lifecycleState: "PUBLISHED",
        isReshareDisabledByAuthor: false,
        distribution: {
          feedDistribution: "MAIN_FEED",
          targetEntities: [],
          thirdPartyDistributionChannels: []
        }
      }

      if image_urn
        image_data = {
          content: {
            media: {
              altText: "",
              id: image_urn
            }
          }
        }
        body.merge!(image_data)
      end
      path = "/posts"
      post(path, MultiJson.dump(body), 'Content-Type' => 'application/json')
    end

    def initialize_image_upload(actor_urn)
      body = {
        initializeUploadRequest: { owner: actor_urn }
      }

      path = "/images?action=initializeUpload"
      post(path, MultiJson.dump(body), 'Content-Type' => 'application/json')
    end

    def upload_image(upload_url, source_url)
      media = URI.open(source_url, 'rb')
      io = StringIO.new(media.read)
      filename = source_url.split("/").last

      file = Faraday::UploadIO.new(io, content_type(media), filename)
      content_length = io.length

      @connection.put(upload_url, file) do |req|
        req.headers['Content-Type'] = 'application/octet-stream'
        req.headers['Accept'] = 'application/json'
        req.headers['Content-Length'] = content_length.to_s
        req.options.timeout = DEFAULT_TIMEOUT_SECONDS
        req.options.open_timeout = DEFAULT_TIMEOUT_SECONDS
      end
    end

    def upload_filename(media)
      File.basename(media.base_uri.request_uri)
    end

    def extension(media)
      # s3 url has a bunch of params after the filename
      upload_filename(media).split('.').last.split('&').first
    end

    def content_type(media)
      ::MIME::Types.type_for(extension(media)).first.content_type
    end

  end
end
