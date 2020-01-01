module LinkedIn
  # Assets API
  #
  # @see https://docs.microsoft.com/en-us/linkedin/marketing/integrations/community-management/shares/vector-asset-api
  class Assets < APIResource
    DEFAULT_RECIPES = ["urn:li:digitalmediaRecipe:feedshare-image"]

    def upload_image(urn, image_io)
      response = register_upload(urn)
      body = JSON.parse(response.body)
      upload_info = body.dig('value', 'uploadMechanism', 'com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest')

      headers = upload_info['headers']
      upload_url = upload_info['uploadUrl']

      asset = body['value']['asset']

      upload_asset(upload_url, image_io, headers)

      asset
    end

    def register_upload(urn, recipes: DEFAULT_RECIPES)
      path = '/assets?action=registerUpload'

      options = {
        registerUploadRequest: {
          recipes: recipes,
          owner: urn,
          serviceRelationships: [
            {
              relationshipType: "OWNER",
              identifier: "urn:li:userGeneratedContent"
            }
          ]
        }
      }

      post(path, MultiJson.dump(options), {'Content-Type': 'application/json'})
    end

    def upload_asset(url, io, headers)
      default_headers = { 'Transfer-Encoding': 'chunked', 'Content-Type': 'application/octet-stream' }
      @connection.post(url, io, default_headers.merge(headers))
    end
  end
end
