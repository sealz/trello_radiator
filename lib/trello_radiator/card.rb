module TrelloRadiator
  ##
  # A Trello Card
  class Card
    attr_accessor :id, :checkItemStates, :desc, :idBoard, :idList, :pos,
                  :name, :idLabels, :shortUrl, :labels, :list, :customFields,
                  :idChecklists, :checklists

    def initialize(attributes = {}, raw = nil, custom_fields = [])
      self.id              = attributes['id']
      self.checkItemStates = attributes['checkItemStates']
      self.desc            = attributes['desc']
      self.idBoard         = attributes['idBoard']
      self.idList          = attributes['idList']
      self.pos             = attributes['pos']
      self.name            = attributes['name']
      self.idLabels        = attributes['idLabels']
      self.shortUrl        = attributes['shortUrl']
      self.idChecklists    = attributes['idChecklists']
      self.checklists      = []

      self.labels = find_matching_labels(raw)
      self.list = find_matching_list(raw)
      self.customFields = apply_custom_fields(
        attributes['customFieldItems'], custom_fields
      )
    end

    def user_story
      return '' unless desc
      match = /\#\# Story\s+(.*)[\#,\b,\s]+/.match(desc)
      return '' unless match
      match.captures.first
    end

    def estimate
      custom_estimate_field = customFields.find do |field|
        field.keys.include?('Estimate')
      end

      return nil unless custom_estimate_field
      estimate = custom_estimate_field.values.first.to_i

      return nil unless estimate > 0

      estimate
    end

    def epic?
      epic_label = labels.find { |label| label.name == 'EPIC' }
      epic_label.nil? ? false : true
    end

    def epic
      custom_estimate_field = customFields.find do |field|
        field.keys.include?('EPIC')
      end

      return nil unless custom_estimate_field
      custom_estimate_field.values.first
    end

    def fetch_checklists
      @client = TrelloRadiator::Client.new
      checklists = @client.get("/cards/#{id}/checklists")
      self.checklists = checklists.map { |c| TrelloRadiator::Checklist.new(c) }
    end

    def remaining_task_time
      checklists.sum(&:time_remaining)
    end

    def estimated_task_time
      checklists.sum(&:time_estimate)
    end

    def actual_task_time
      checklists.sum(&:time_actual)
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
