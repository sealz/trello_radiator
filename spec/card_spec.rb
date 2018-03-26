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
      'id' => '5ab486acd7e4e71287b3df68',
      'checkItemStates' => nil,
      'desc' => '## Story\n\nAs a user, I want to complete all of my '\
                '"paperwork" while registering so that I can just use '\
                'the app when I\'m done',
      'idBoard' => '5ab437592984e238acb4d440',
      'idList' => '5ab437a064db2e0d5ff28ecb',
      'pos' => 49_151.5,
      'name' => 'Finnovate Delighters',
      'idLabels' => %w[
        5ab439495b0111777417b64f
        5ab482d4d78523e1e5bac99d
        5ab440a05425d4a247518505
      ],
      'shortUrl' => 'https://trello.com/c/mrVKcrOs',
      'customFieldItems' => [
        {
          'id' => '5ab5408492b0cc36b94bdc65',
          'value' => { 'text' => 'FINNOVATE' },
          'idCustomField' => '5ab442f339cfc095dfd89dda',
          'idModel' => '5ab486acd7e4e71287b3df68',
          'modelType' => 'card'
        }
      ]
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
        expect(sut.customFields).to include('EPIC' => 'FINNOVATE')
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
