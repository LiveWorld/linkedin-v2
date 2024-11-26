module LinkedIn

  # https://learn.microsoft.com/en-us/linkedin/marketing/community-management/shares/reactions-api?view=li-lms-2024-10&tabs=http#create-a-reaction-on-a-share
  class Reactions < APIResource


    # POST https://api.linkedin.com/rest/reactions?actor={encoded organizationUrn|encoded personUrn}
    # {
    #     "root": "urn:li:comment:(urn:li:activity:6666,120381273128)",
    #     "reactionType": "{REACTION_TYPE}"
    # }

    def create_reaction(params)
      body = {
        root: params[:root],
        reactionType: params[:reaction_type]
      }

      path = "/reactions?actor=#{CGI::escape(params[:actor_id])}"
      post(path, MultiJson.dump(body), headers)
    end

    # DELETE https://api.linkedin.com/rest/reactions/(actor:{encoded personUrn|encoded organizationUrn},entity:{encoded shareUrn|encoded ugcPostUrn|encoded commentUrn})

    def delete_reaction(params)
      actor = CGI::escape(params[:actor])
      entity = CGI::escape(params[:entity])
      path = "/reactions/(actor:#{actor},entity:#{entity})"

      delete(path, nil, headers, true)
    end

    def headers
      { 'Content-Type' => 'application/json' }
    end

  end

end
