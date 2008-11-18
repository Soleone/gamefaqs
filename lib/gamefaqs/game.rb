module GameFaqs  
  class Game
    
    GENRES = { "Action" => "54", "Action-Adventure" => "163", "Adventure" => "50", "Driving" => "47", "Miscellaneous" => "49", "Role-Playing" => "48", "Simulation" => "46", "Sports" => "43", "Strategy" => "45"}
    
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
    
    def questions
      List.questions(self)
    end
    
    def average_score(review_type=nil)
      sum = reviews(review_type).map{|r| r.score_to_i}.inject{|memo, score| memo + score}
      sum ? (sum / reviews(review_type).size.to_f) : -1
    end
    
    def average_score_to_s
      "%.2f - #{to_s}" % average_score
    end
    
    def self.find(game, platform)
      Search.game(game, platform)
    end
  end
end