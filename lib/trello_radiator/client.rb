require 'httparty'

module TrelloRadiator
  ##
  # A wrapper around the Trello REST API
  class Client
    def initialize(token = nil, key = nil, base_url = nil)
      raise ArgumentError, 'A token is required' unless token
      raise ArgumentError, 'A key is required' unless key
      @key   = key || ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
      @token = token || ENV['TRELLO_MEMBER_TOKEN']
      @url   = base_url || 'https://api.trello.com/api/1'
    end

    def get(resource)
      HTTParty.get(url_appending_auth(resource))
    end

    private

    def url_appending_auth(resource)
      uri = URI.parse("#{@url}#{resource}")
      with_auth = URI.decode_www_form(uri.query || '')
      with_auth << ['token', @token]
      with_auth << ['key', @key]
      uri.query = URI.encode_www_form(with_auth)
      uri.to_s
    end
  end
end
