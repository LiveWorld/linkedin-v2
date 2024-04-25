module LinkedIn

  class Images < APIResource

    def batched_images(options={})
      image_urns = options.delete(:image_urns)
      get("/images?ids=List(#{image_urns})", options)
    end

  end

end