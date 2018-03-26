module TrelloRadiator
  ##
  # A Custom Field
  class CustomField
    attr_accessor :id, :idModel, :modelType, :fieldGroup, :name, :pos,
                  :options, :type
    def initialize(attributes)
      self.id         = attributes['id']
      self.idModel    = attributes['idModel']
      self.modelType  = attributes['modelType']
      self.fieldGroup = attributes['fieldGroup']
      self.name       = attributes['name']
      self.pos        = attributes['pos']
      self.options    = attributes['options']
      self.type       = attributes['type']
    end
  end
end
