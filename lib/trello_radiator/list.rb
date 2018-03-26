module TrelloRadiator
  ##
  # A List
  class List
    attr_accessor :id, :name, :closed, :pos, :idBoard, :subscribed, :cards
    def initialize(attributes, all_cards = [])
      self.id         = attributes['id']
      self.name       = attributes['name']
      self.closed     = attributes['closed']
      self.pos        = attributes['pos']
      self.idBoard    = attributes['idBoard']
      self.subscribed = attributes['subscribed']

      self.cards = find_child_cards(all_cards)
    end

    private

    def find_child_cards(all_cards)
      return [] unless all_cards
      all_cards.select { |card| card.idList == id }.compact
    end
  end

  ##
  # An empty nothing list
  class NullList < List
    def initialize(*); end
  end
end
