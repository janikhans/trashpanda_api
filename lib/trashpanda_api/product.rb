require 'money'

module TrashpandaAPI
  class Product
    attr_accessor :id, :asin, :title, :price, :coupon, :manufacturer_name,
                  :description, :bullet_points, :selling_since, :reviews_count,
                  :featured_image, :relevant, :last_scraped, :scrape_status,
                  :in_stock, :scrape_error, :parent

    def initialize(params = {})
      self.parent = TrashpandaAPI::Parent.new(params.delete('parent')) if params['parent']
      if params['last_scraped']
        self.last_scraped = DateTime.parse(params.delete('last_scraped')).in_time_zone('Pacific Time (US & Canada)')
      end
      self.price = Money.new(params.delete('price')['cents']) if params['price']
      self.coupon = Money.new(params.delete('coupon')['cents']) if params['coupon']
      self.bullet_points = params.delete('bullet_points') || []

      params.each do |param|
        accessor = "#{param.first}="

        next unless respond_to?(accessor)

        send(accessor, param.second)
      end
    end

    def self.find(asin)
      response = TrashpandaAPI::Request.get("products/#{asin}.json")
      new(response.parsed_response)
    end

    def self.scrape!(asin)
      TrashpandaAPI::Request.post("products/#{asin}/scrape.json")
    end

    def scrape!
      return unless status == 'ready'

      self.class.scrape!(asin)
    end

    def status
      scrape_status
    end

    def ready?
      status == 'ready'
    end
  end
end
