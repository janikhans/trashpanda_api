require 'trashpanda_api/errors/failed_request'
require 'trashpanda_api/errors/resource_not_found'
require 'httparty'

module TrashpandaAPI
  class Request
    def initialize(url:, method:, options: {})
      @url = build_url(url, options[:url_params])
      @method = method
      @options = {
        headers: { 'Authorization' => "Token #{ENV['TRASHPANDA_API_TOKEN']}" }
      }
    end

    def process!
      response = HTTParty.send(@method, @url, @options)

      case response.code
      when 200
        response
      when 404
        raise ResourceNotFound.new
      else
        raise FailedRequest.new(response.body)
      end
    end

    def self.get(url)
      new(url: url, method: :get).process!
    end

    def self.post(url)
      new(url: url, method: :post).process!
    end

    private

    def build_url(url, url_params)
      url = "https://www.trashpanda.xyz/api/#{url}"
      url += "?#{URI.encode_www_form(camelcase_keys(url_params))}" if url_params
      url
    end
  end
end