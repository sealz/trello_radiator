module TrelloRadiator
  ##
  # A Label
  class Label
    attr_accessor :id, :idBoard, :name, :color, :uses

    def initialize(data)
      self.id       = data['id']
      self.idBoard  = data['idBoard']
      self.name     = data['name']
      self.color    = data['color']
      self.uses     = data['uses'] || 0
    end
  end
end
