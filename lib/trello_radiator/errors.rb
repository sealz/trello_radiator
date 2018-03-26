module TrelloRadiator
  module Errors
    class Error < StandardError; end

    #
    ## A missing identifier error
    class MissingIdentifier < Error; end
  end
end
