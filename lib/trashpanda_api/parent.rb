module TrashpandaAPI
  class Parent
    attr_accessor :id, :asin, :reviews, :rating, :product_count

    def initialize(params = {})
      params.each do |param|
        accessor = "#{param.first}="

        next unless respond_to?(accessor)

        send(accessor, param.second)
      end
    end
  end
end
