module LinkedIn

  class Images < APIResource

    def batched_images(options={})
      image_urns = options.delete(:image_urns)
      # formatted_person_ids = person_ids.map{|id| "(id:#{id})"}.join(',')
      p "urns: #{image_urns}"
      get("/images?ids=List(#{image_urns})", options)
    end

  end

end