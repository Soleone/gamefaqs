module GameFaqs
  class Review
    REVIEW_TYPES = [:detailed, :full, :quick]
    
    attr_reader :game, :id, :score, :author, :title, :type
    
    def initialize(options={})
      raise ArgumentError.new("Need at least the game and the review id") unless options[:game] && options[:id]
      @game, @id, @score, @author, @title, @type = options[:game], options[:id], options[:score], options[:author], options[:title], options[:type]
    end
    
    def to_s
      "#{@game}: #{@score} by #{author} (#{@title} [#{@type}])"
    end

    def score_to_i
      actual, max = @score.split("/")
      factor = 10 / max.to_i
      actual.to_i * factor
    end
        
    def self.all_for(game)
      List.reviews(game)
    end
    
    def self.review_type(string)
      REVIEW_TYPES.each do |type|
        return type if string =~ /#{type}/i
      end
    end  
  end
end