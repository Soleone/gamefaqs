module GameFaqs  
  module Random
    extend self
    
    # A review for a game
    def review(game, platform=game.platform)
      game = Search.game(game, platform) if game.is_a?(String)
      game and random(game.reviews)
    end
    
    # Return the title and the score of a review
    def one_line_review(game, platform=game.platform, options={:detailed => false})
      rev = review(game, platform)
      rev and "#{options[:detailed] ? (rev.game.to_s << ': ') : ''}\"#{rev.title}\" - #{rev.score}"
    end
    alias :opinion :one_line_review
    
    def question(game, platform=game.platform)
      game = Search.game(game, platform) if game.is_a?(String)
      game and random(game.questions)
    end
    
  private
    def random(array)
      array[rand(array.size)]
    end
  end
end