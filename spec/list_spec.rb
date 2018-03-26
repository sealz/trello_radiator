require 'spec_helper'

RSpec.describe TrelloRadiator::List do
  describe 'creating a new List' do
    before do
      @fixture = JSON.parse(
        File.read(
          File.join(
            File.dirname(__FILE__), 'fixtures', 'board_fetch_response.json'
          )
        )
      )

      @attributes = {
        'id'      => '5ab437a064db2e0d5ff28ecb',
        'name'    => 'User Experience',
        'closed'  => false,
        'pos'     => 49_151.25,
        'idBoard' => '5ab437592984e238acb4d440',
        'subscribed' => false
      }

      @cards = [
        TrelloRadiator::Card.new('idList' => 'not-5ab437a064db2e0d5ff28ecb'),
        TrelloRadiator::Card.new('idList' => '5ab437a064db2e0d5ff28ecb'),
        TrelloRadiator::Card.new('idList' => '5ab437a064db2e0d5ff28ecb')
      ]
    end

    it 'assigns values from the passed attributes' do
      sut = TrelloRadiator::List.new(@attributes)

      expect(sut.id).to eq('5ab437a064db2e0d5ff28ecb')
      expect(sut.name).to eq('User Experience')
      expect(sut.closed).to be false
      expect(sut.pos).to eq(49_151.25)
      expect(sut.idBoard).to eq('5ab437592984e238acb4d440')
      expect(sut.subscribed).to be false
    end

    context 'with a list of cards' do
      it 'properly assigns the cards to their list' do
        sut = TrelloRadiator::List.new(@attributes, @cards)
        expect(sut.cards).to be
        expect(sut.cards.size).to eq(2)
      end
    end
  end
end
