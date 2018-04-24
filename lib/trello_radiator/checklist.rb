module TrelloRadiator
  ##
  # A Trello Checklist
  class Checklist
    attr_accessor :name, :nameData, :pos, :idBoard,
                  :idCard, :items

    def initialize(attributes)
      self.name     = attributes['name']
      self.nameData = attributes['nameData']
      self.pos      = attributes['pos']
      self.idBoard  = attributes['idBoard']
      self.idCard   = attributes['idCard']
      self.items    = attributes['checkItems'].map { |i| ChecklistItem.new(i) }
    end

    def time_estimate
      items.sum(&:time_estimate)
    end

    def time_remaining
      items.select { |item| item.state == 'incomplete' }.sum(&:time_estimate)
    end

    def time_actual
      items.sum(&:time_actual)
    end
  end

  ##
  # A checklist item
  class ChecklistItem
    attr_accessor :state, :idChecklist, :id, :name, :nameData, :pos

    def initialize(attributes)
      self.state       = attributes['state']
      self.idChecklist = attributes['idChecklist']
      self.id          = attributes['id']
      self.name        = attributes['name']
      self.nameData    = attributes['nameData']
      self.pos         = attributes['pos']
    end

    def time_estimate
      estimate = /\[([\d,.]+)\]/.match(name)
      return 0 unless estimate
      estimate.captures.first.to_f
    end

    def time_actual
      actual = /\{([\d,.]+)\}/.match(name)
      return 0 unless actual
      actual.captures.first.to_f
    end
  end
end
