module LinkedIn

  class Webhooks < APIResource

    # PUT https://api.linkedin.com/v2/eventSubscriptions/(
    # developerApplication:urn:li:developerApplication:{developer application ID},
    # user:urn:li:user:{member ID},
    # entity:urn:li:organization:{organization ID},
    # eventType:ORGANIZATION_SOCIAL_ACTION_NOTIFICATIONS)

    # https://api.linkedin.com/v2/eventSubscriptions/(
    # developerApplication:{URL_ENCODED_APPLICATION_URN},
    # user:{URL_ENCODED_PERSON_URN},
    # entity:{URL_ENCODED_ORGANIZATION_URN},
    # eventType:ORGANIZATION_SOCIAL_ACTION_NOTIFICATIONS)

    def subscribe_to_webhooks(application_id, member_id, organization_id, webhook_url)
      application_urn = CGI::escape("urn:li:developerApplication:#{application_id}")
      user_urn = CGI::escape("urn:li:person:#{member_id}")
      organization_urn = CGI::escape("urn:li:organization:#{organization_id}")
      event_type = "ORGANIZATION_SOCIAL_ACTION_NOTIFICATIONS"

      path = "/eventSubscriptions/(developerApplication:#{application_urn},user:#{user_urn},entity:#{organization_urn},eventType:#{event_type})"

      response = put(path, { "webhook" => webhook_url }.to_json)
      response&.status
    end

    # https://api.linkedin.com/v2/organizationalEntityNotifications?q=criteria&count=100&actions=List(COMMENT,SHARE,SHARE_MENTION,ADMIN_COMMENT,COMMENT_EDIT,COMMENT_DELETE)&organizationalEntity=urn%3Ali%3Aorganization%3A11163215
    def webhook_notifications(options)
      organization_urn = CGI::escape("urn:li:organization:#{options[:organization_id]}")
      count = options[:count] || '100'
      actions = options[:actions] || 'COMMENT,SHARE,SHARE_MENTION,ADMIN_COMMENT,COMMENT_EDIT,COMMENT_DELETE'

      # We have to build the query string manually
      # It would be nice & clean to create a Hash of the params & call #to_query on it,
      # but only the organizationEntity urn can be encoded otherwise the API call will fail
      query_string = "q=criteria&count=#{count}&actions=List(#{actions})&organizationalEntity=#{organization_urn}"

      if options[:time_start] || options[:time_end]
        # If time_start is supplied use that, otherwise default to 24 hours ago
        time_start = options[:time_start] || 24.hours.ago * 1000

        # If time_end is supplied use that, otherwise default to now
        time_end = options[:time_end] || Time.now.to_i * 1000
        query_string += "&timeRange=(start:#{time_start},end:#{time_end})"
      end

      path = "/organizationalEntityNotifications?#{query_string}"
      LinkedIn::APICollection.new(get(path, {}), @connection)
    end
  end
end
