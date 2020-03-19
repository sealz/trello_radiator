module TrelloRadiator
  ##
  # A Trello Card
  class Card
    attr_accessor :id, :checkItemStates, :desc, :idBoard, :idList, :pos,
                  :name, :idLabels, :shortUrl, :labels, :list, :customFields,
                  :idChecklists, :checklists

    def initialize(attributes = {}, raw = nil, custom_fields = [])
      self.id              = attributes['id']
      self.desc            = attributes['desc']
      self.idBoard         = attributes['idBoard']
      self.idList          = attributes['idList']
      self.pos             = attributes['pos']
      self.name            = attributes['name']
      self.idLabels        = attributes['idLabels']
      self.shortUrl        = attributes['shortUrl']

      self.labels = find_matching_labels(raw)
      self.list = find_matching_list(raw)
      self.customFields = apply_custom_fields(
        attributes['customFieldItems'], custom_fields
      )
    end

    private

    def apply_custom_fields(mine, all)
      return [] if mine.nil?
      return [] if all.nil?
      mapped = []
      mine.each do |field|
        next unless field
        next unless field['value']
        match = all.find { |f| f.id == field['idCustomField'] }
        next unless match
        mapped << {
          match.name.to_s => field['value'][match.type.to_s]
        }
      end

      mapped
    end

    def find_matching_list(raw)
      null_list = TrelloRadiator::NullList.new
      return null_list unless raw

      match = raw['lists'].find { |list| list['id'] == idList }
      return null_list unless match

      TrelloRadiator::List.new(match)
    end

    def find_matching_labels(raw)
      return [] unless raw
      matches = raw['labels'].select { |label| idLabels.include?(label['id']) }
      matches.compact.map { |label| Label.new(label) }
    end
  end
end
