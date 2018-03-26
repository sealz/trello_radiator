module TrelloRadiator
  #
  ## A Trello Board
  class Board
    attr_accessor :id, :name, :descData, :shortUrl, :labels, :cards, :lists,
                  :custom_fields

    def initialize(identifier = nil, client = nil, options = {})
      raise TrelloRadiator::Errors::MissingIdentifier if identifier.nil?
      @identifier = identifier
      @client = client || TrelloRadiator::Client.new

      autoload = options[:autoload] || options['autoload'] || nil
      fetch if autoload
    end

    def fetch
      board = @client.get("/boards/#{@identifier}?lists=open&labels=all")
      self.id             = board['id']
      self.name           = board['name']
      self.descData       = board['descData']
      self.shortUrl       = board['shortUrl']

      self.labels = board['labels'].map { |label| Label.new(label) }
      self.lists  = board['lists'].map { |list| List.new(list) }

      custom_fields = @client.get("/boards/#{@identifier}/customFields")
      self.custom_fields = custom_fields.map { |field| CustomField.new(field) }

      cards = @client.get(
        "/boards/#{@identifier}/cards?customFieldItems=true&fields=" \
        'id,checkItemStates,desc,idBoard,idList,pos,name,idLabels,shortUrl'
      )

      self.cards = cards.map { |card| Card.new(card, board) }
    end
  end
end
