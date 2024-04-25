module LinkedIn

  class Ads < APIResource

    # This requires the URN to be encoded, so we need to use the protocol v2 connection
    # this is ok until @api_version = "202307"
    def ad_direct_sponsored_contents(options = {})
      urn = options.delete(:urn)
      path = "/adDirectSponsoredContents?owner=#{CGI::escape(urn)}&q=owner"
      LinkedIn::APICollection.new(get(path, options), @connection)
    end

  end
end
