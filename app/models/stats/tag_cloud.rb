# tag cloud code inspired by this article
#  http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/
module Stats
  class TagCloud

    attr_reader :levels, :tags
    def initialize(tags)
      @levels = 10
      @tags = tags.sort_by { |tag| tag.name.downcase }
    end

    def empty?
      tags.empty?
    end

    def relative_size(tag)
      (tag.count - min) / divisor
    end

    private

    def max
      @max ||= counts.max
    end

    def min
      @min ||= counts.min
    end

    def divisor
      @divisor ||= ((max - min) / levels) + 1
    end

    def counts
      @counts ||= tags.map {|t| t.count}
    end
  end
end
