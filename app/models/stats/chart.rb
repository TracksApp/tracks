module Stats

  class Chart

    attr_reader :action, :height, :width
    def initialize(action, dimensions = {})
      @action = action
      @height = dimensions.fetch(:height) { 250 }
      @width = dimensions.fetch(:width) { 460 }
    end

    def dimensions
      "#{width}x#{height}"
    end

  end

end
