module GameFaqs  
  class Game

    attr_reader :name, :platform, :homepage, :faqs, :codes
    
    def initialize(name, platform, id)
      @name = name
      @platform = platform
      @id = id
      @homepage = "#{@platform.homepage}home/#{@id}.html"
    end

    def name
      "#{@name} (#{@platform})"
    end
    
    def to_s
      "#{@name} [#{platform}]"
    end
    
    def reviews(review_type=nil)
      List.reviews(self, review_type)
    end
    
    def average_score(review_type=nil)
      sum = reviews(review_type).map{|r| r.score_to_i}.inject{|memo, score| memo + score}
      sum / reviews(review_type).size.to_f
    end
    
  end
end