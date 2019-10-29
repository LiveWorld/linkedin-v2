module LinkedIn

  class APICollection

    attr_accessor :elements, :paging, :connection

    def initialize(mash, connection)
      @elements = mash.elements
      @paging = mash.paging
      @connection = connection
    end

    def has_results?
      elements.present?
    end

    def next_page
      response = connection.get(next_page_url)
      results = Mash.from_json(response.body)
      LinkedIn::APICollection.new(results, connection)
    end

    def count
      paging.dig('count')
    end

    def total
      paging.dig('total')
    end

    def next_page_url
      next_page_link = paging.dig('links')&.select{ |link| link['rel'] == 'next' }
      next_page_link&.dig(0, 'href')
    end

    def previous_page_url
      previous_page_link = paging.dig('links')&.select{ |link| link['rel'] == 'prev' }
      previous_page_link&.dig(0, 'href')
    end
  end
end