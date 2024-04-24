module LinkedIn

  # class APIV202307 < APIResource
  class DeprecatedAPI < APIResource

    def migrate_update_keys(update_keys)
      path = '/activities'
      get(path, ids: update_keys)
    end

  end
end
