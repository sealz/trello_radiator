require 'spec_helper'

RSpec.describe TrelloRadiator::Card do
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

    @custom_fields = @custom_field_fixture.map do |field|
      TrelloRadiator::CustomField.new(field)
    end

    @attributes = {
      'id' => '5ab440341b88cd6dd42308b5',
      'checkItemStates' => nil,
      'desc' => '## Story\n\nAs a user, I want to be able to quickly scan the '\
                'TruCode when I\'m using the gateway so that I don\'t have to '\
                'sit through a long animation to get where I\'m going\n\nMore '\
                'details: https://trello.com/c/ZMm6Mqlh',
      'idBoard' => '5ab437592984e238acb4d440',
      'idList' => '5ab437a064db2e0d5ff28ecb',
      'pos' => 98_303,
      'name' => 'Shorten Gateway Animation',
      'idLabels' => %w[
        5ab4408f6acb2938fb0dcfdc
        5ab43759841642c2a8541ca2
        5ab43e2c94ab7f9aeacdda23
        5ab440a05425d4a247518505'
      ],
      'shortUrl' => 'https://trello.com/c/yGK57u4P',
      'customFieldItems' => [{
        'id' => '5ab44424e5c8c034f8824dcf',
        'value' => { 'text' => 'FINOVATE' },
        'idCustomField' => '5ab442f339cfc095dfd89dda',
        'idModel' => '5ab440341b88cd6dd42308b5',
        'modelType' => 'card'
      },
      {
        'id' => '5abb2b7da8bcf2396fec3b20',
        'value' => {
          'number' => '5'
        },
        'idCustomField' => '5abb2b7ab764420bcbf04a89',
        'idModel' => '5ab440341b88cd6dd42308b5',
        'modelType' => 'card'
      }]
    }
  end

  describe 'creating a new card' do
    it 'sets all of the fields from the passed in attributes' do
      sut = TrelloRadiator::Card.new(@attributes)

      expect(sut.id).to eq(@attributes['id'])
      expect(sut.checkItemStates).to eq(@attributes['checkItemStates'])
      expect(sut.desc).to eq(@attributes['desc'])
      expect(sut.idBoard).to eq(@attributes['idBoard'])
      expect(sut.idList).to eq(@attributes['idList'])
      expect(sut.pos).to eq(@attributes['pos'])
      expect(sut.name).to eq(@attributes['name'])
      expect(sut.idLabels).to eq(@attributes['idLabels'])
      expect(sut.shortUrl).to eq(@attributes['shortUrl'])
    end

    context 'when custom field data ia passed in' do
      it 'applies the correct custom fields and values' do
        sut = TrelloRadiator::Card.new(@attributes, nil, @custom_fields)
        expect(sut.customFields).to include('EPIC' => 'FINOVATE')
        expect(sut.customFields).to include('Estimate' => '5')
      end
    end

    context 'when raw board data is passed in' do
      it 'assigns the matching labels' do
        sut = TrelloRadiator::Card.new(@attributes, @fixture)
        expect(sut.labels).to be
        expect(sut.labels.size).to eq(3)
        expect(sut.labels.first).to be_a(TrelloRadiator::Label)
      end

      it 'assigns the parent list' do
        sut = TrelloRadiator::Card.new(@attributes, @fixture)
        expect(sut.list).to be
        expect(sut.list).to be_a(TrelloRadiator::List)
        expect(sut.list.id).to eq(sut.idList)
      end

      context 'and there are no labels in the raw data' do
        it 'assigns an empty list as the labels' do
          sut = TrelloRadiator::Card.new(@attributes, nil)
          expect(sut.labels).to be_empty
          expect(sut.labels.size).to eq(0)
        end
      end
    end
  end

  describe 'parsing the user story' do
    context 'when there is a story header and other headers' do
      it 'takes everything after the story header, but before other content' do
        sut = TrelloRadiator::Card.new(
          'desc' => "## Story\n\nTHIS IS THE STORY\n## Examples"
        )

        expect(sut.user_story).to eq('THIS IS THE STORY')
      end
    end
  end

  describe 'determining if the card is an epic' do
    context 'when it is an epic' do
      it 'then it should be obvious' do
        sut = TrelloRadiator::Card.new({}, nil, [])
        sut.labels = [TrelloRadiator::Label.new('name' => 'EPIC')]

        expect(sut.epic?).to be true
      end
    end
    context 'when it is not an epic' do
      it 'then it should be obvious' do
        sut = TrelloRadiator::Card.new({}, nil, [])
        sut.labels = []

        expect(sut.epic?).to be false
      end
    end
  end

  describe 'determining the associated epic' do
    context 'when the epic is set' do
      it 'should return the specified value' do
        sut = TrelloRadiator::Card.new({}, nil, [])
        sut.customFields = ['EPIC' => 'Reporting']
        expect(sut.epic).to eq('Reporting')
      end
    end

    context 'when the epic is not set' do
      it 'should return nothing' do
        sut = TrelloRadiator::Card.new({}, nil, [])
        sut.customFields = []
        expect(sut.epic).to be_nil
      end
    end
  end

  describe 'determining the estimate' do
    context 'when the estimate is set' do
      it 'should return the specified value' do
        sut = TrelloRadiator::Card.new({}, nil, [])
        sut.customFields = ['Estimate' => '5']
        expect(sut.estimate).to eq(5)
      end
    end

    context 'when the estimate is not set' do
      it 'should return nothing' do
        sut = TrelloRadiator::Card.new({}, nil, [])
        sut.customFields = []
        expect(sut.estimate).to be_nil
      end
    end

    context 'when the estimate is not an integer' do
      it 'should return nothing' do
        sut = TrelloRadiator::Card.new({}, nil, [])
        sut.customFields = ['Estimate' => 'apple']
        expect(sut.estimate).to be_nil
      end
    end
  end
end
