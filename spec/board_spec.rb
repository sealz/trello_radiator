require 'spec_helper'

RSpec.describe TrelloRadiator::Board do
  before do
    @fixture = JSON.parse(
      File.read(
        File.join(
          File.dirname(__FILE__), 'fixtures', 'board_fetch_response.json'
        )
      )
    )

    @custom_field_fixture = JSON.parse(
      File.read(
        File.join(
          File.dirname(__FILE__), 'fixtures', 'custom_field_response.json'
        )
      )
    )

    @cards_fixture = JSON.parse(
      File.read(
        File.join(
          File.dirname(__FILE__), 'fixtures', 'cards_response.json'
        )
      )
    )

    @stub_client = double(get: @fixture)

    allow(@stub_client).to(
      receive(:get).with('/boards/my-board?lists=open&labels=all')
    ).and_return(@fixture)

    allow(@stub_client).to(
      receive(:get).with('/boards/my-board/customFields')
    ).and_return(@custom_field_fixture)

    allow(@stub_client).to(
      receive(:get).with(
        '/boards/my-board/cards?customFieldItems=true&fields=id,'\
        'checkItemStates,desc,idBoard,idList,pos,name,idLabels,shortUrl'
      )
    ).and_return(@cards_fixture)
  end

  describe 'instantiating a new board' do
    it 'requires a board identifier' do
      expect { TrelloRadiator::Board.new }.to(
        raise_error(TrelloRadiator::Errors::MissingIdentifier)
      )
    end

    it 'optionally accepts an api client' do
      expect { TrelloRadiator::Board.new('myboard', @stub_client) }.to_not(
        raise_error
      )
    end

    it 'uses a default client' do
      expect(TrelloRadiator::Client).to receive(:new).and_return(@stub_client)
      TrelloRadiator::Board.new('my-board')
    end

    it 'optionally allows for immediating fetching of the board\'s contents' do
      expect(@stub_client).to receive(:get)
      TrelloRadiator::Board.new('my-board', @stub_client, autoload: true)
    end
  end

  describe 'fetching the board' do
    it 'tells the client to retreive the board' do
      expect(@stub_client).to(
        receive(:get).with('/boards/my-board?lists=open&labels=all').once
      )
      sut = TrelloRadiator::Board.new('my-board', @stub_client)
      sut.fetch
    end

    it 'tells the client to retrieve the custom fields for the board' do
      expect(@stub_client).to(
        receive(:get).with('/boards/my-board/customFields').once
      )
      sut = TrelloRadiator::Board.new('my-board', @stub_client)
      sut.fetch
    end

    it 'tells the client to retrieve the cards on the board' do
      expect(@stub_client).to(
        receive(:get).with(
          '/boards/my-board/cards?customFieldItems=true&fields='\
          'id,checkItemStates,desc,idBoard,idList,pos,name,idLabels,shortUrl'
        ).once
      )
      sut = TrelloRadiator::Board.new('my-board', @stub_client)
      sut.fetch
    end

    it 'tells the client to fetch associated lists and labels' do
      expect(@stub_client).to(
        receive(:get).with('/boards/my-board?lists=open&labels=all')
      )
      sut = TrelloRadiator::Board.new('my-board', @stub_client)
      sut.fetch
    end

    context 'when it goes well' do
      it 'populates the board\'s fields' do
        sut = TrelloRadiator::Board.new('my-board', @stub_client)
        sut.fetch

        expect(sut.id).to be
        expect(sut.id).to eq(@fixture['id'])

        expect(sut.name).to be
        expect(sut.name).to eq(@fixture['name'])

        # no presence expectation because it's actually null
        expect(sut.descData).to eq(@fixture['descData'])

        expect(sut.shortUrl).to be
        expect(sut.shortUrl).to eq(@fixture['shortUrl'])
      end

      it 'populates the custom fields' do
        sut = TrelloRadiator::Board.new('my-board', @stub_client)
        sut.fetch

        expect(sut.custom_fields).to be
        expect(sut.custom_fields.first).to be_a(TrelloRadiator::CustomField)
      end

      it 'populates the labels' do
        sut = TrelloRadiator::Board.new('my-board', @stub_client)
        sut.fetch

        expect(sut.labels).to be
        expect(sut.labels.size).to eq(26)
        expect(sut.labels.first).to be_a TrelloRadiator::Label
        expect(sut.labels.first.id).to eq('5ab43759841642c2a8541ca2')
        expect(sut.labels.first.idBoard).to eq('5ab437592984e238acb4d440')
        expect(sut.labels.first.name).to eq('Story')
        expect(sut.labels.first.color).to eq('green')
        expect(sut.labels.first.uses).to eq(20)
      end

      it 'populates the cards' do
        sut = TrelloRadiator::Board.new('my-board', @stub_client)
        sut.fetch

        expect(sut.cards).to be
        expect(sut.cards.size).to eq(36)
        expect(sut.cards.first).to be_a TrelloRadiator::Card
        expect(sut.cards.first.id).to eq @cards_fixture[0]['id']
        expect(sut.cards.first.checkItemStates).to(
          eq @cards_fixture[0]['checkItemStates']
        )
        expect(sut.cards.first.desc).to eq @cards_fixture[0]['desc']
        expect(sut.cards.first.idBoard).to eq @cards_fixture[0]['idBoard']
        expect(sut.cards.first.idList).to eq @cards_fixture[0]['idList']
        expect(sut.cards.first.pos).to eq @cards_fixture[0]['pos']
        expect(sut.cards.first.name).to eq @cards_fixture[0]['name']
        expect(sut.cards.first.idLabels).to eq @cards_fixture[0]['idLabels']
        expect(sut.cards.first.shortUrl).to eq @cards_fixture[0]['shortUrl']
      end

      it 'populates the lists' do
        sut = TrelloRadiator::Board.new('my-board', @stub_client)
        sut.fetch

        expect(sut.lists).to be
        expect(sut.lists.size).to eq(4)
        expect(sut.lists.first).to be_a TrelloRadiator::List
        expect(sut.lists.first.id).to eq(@fixture['lists'][0]['id'])
        expect(sut.lists.first.name).to eq(@fixture['lists'][0]['name'])
        expect(sut.lists.first.closed).to eq(@fixture['lists'][0]['closed'])
        expect(sut.lists.first.pos).to eq(@fixture['lists'][0]['pos'])
        expect(sut.lists.first.idBoard).to eq(@fixture['lists'][0]['idBoard'])
        expect(sut.lists.first.subscribed).to(
          eq(@fixture['lists'][0]['subscribed'])
        )
      end
    end
  end
end
