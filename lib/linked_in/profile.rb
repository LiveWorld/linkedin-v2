module LinkedIn

  class Profile < APIResource

    # https://api.linkedin.com/v2/people?ids=List((id:HuTQUpucZ-),(id:JFqso0uiYg),(id:VGWfJE8tU6))
    def people(options={})
      person_ids = options.delete(:person_ids)
      formatted_person_ids = person_ids.map{|id| "(id:#{id})"}.join(',')
      get("/people?ids=List(#{formatted_person_ids})", options)
    end

  end

end