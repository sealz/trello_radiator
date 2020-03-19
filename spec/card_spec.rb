require 'spec_helper'

RSpec.describe TrelloRadiator::Card do
  describe 'creating a new card' do
    it 'sets all of the fields from the passed in attributes' do
      sut = TrelloRadiator::Card.new(@attributes)

      expect(sut.id).to eq(@attributes['id'])
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
      end
    end

    context 'when raw board data is passed in' do
      it 'assigns the matching labels' do
        sut = TrelloRadiator::Card.new(@attributes, @fixture)
        expect(sut.labels).to be
        expect(sut.labels.size).to eq(1)
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
end
