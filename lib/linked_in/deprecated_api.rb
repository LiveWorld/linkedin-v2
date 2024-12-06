module LinkedIn

  # https://learn.microsoft.com/en-us/linkedin/marketing/community-management/shares/share-api?view=li-lms-unversioned&tabs=http#retrieve-activities-and-their-shares
  # {"results":{"urn:li:activity:6592076179065368576":{"domainEntity":"urn:li:share:6592076178587209728"}},"statuses":{},"errors":{}}
  # Using the v2 unversioned endpoints which will be sunset at some point - no timeline given by LI
  class DeprecatedAPI < APIResource

    def migrate_update_keys(update_keys)
      path = '/activities'
      get(path, ids: update_keys)
    end

  end
end
