require 'spec_helper'

RSpec.describe TrelloRadiator::Client do
  describe 'creating a new client' do
    it 'requires a token' do
      ENV['TRELLO_MEMBER_TOKEN'] = nil
      expect { TrelloRadiator::Client.new(nil, 'key') }.to(
        raise_error(ArgumentError, 'A token is required')
      )
    end

    it 'requires a key' do
      ENV['TRELLO_DEVELOPER_PUBLIC_KEY'] = nil
      expect { TrelloRadiator::Client.new('token', nil) }.to(
        raise_error(ArgumentError, 'A key is required')
      )
    end

    it 'optionally accepts a base url' do
      TrelloRadiator::Client.new('t', 'k', 'https://httpbin.org')
    end
  end

  describe 'getting a resource' do
    it 'appends the token and key' do
      expect(HTTParty).to receive(:get).with('https://httpbin.org/get?token=t&key=k')
      sut = TrelloRadiator::Client.new('t', 'k', 'https://httpbin.org')
      sut.get('/get')
    end

    context 'when there are other query string params' do
      it 'merges the token and key' do
        expect(HTTParty).to receive(:get).with(
          'https://httpbin.org/get?foo=bar&token=t&key=k'
        )

        sut = TrelloRadiator::Client.new('t', 'k', 'https://httpbin.org')
        sut.get('/get?foo=bar')
      end
    end
  end
end
