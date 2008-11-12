module GameFaqs  
  module Random
    extend self
    
    # A review for a game
    def review(game, platform)
      game = Search.game(game, platform) if game.is_a?(String)
      game and game.reviews[rand(game.reviews.size)]
    end
    
    def one_line_review(game, platform, options={:detailed => false})
      rev = review(game, platform)
      rev and "#{options[:detailed] ? (rev.game.to_s << ': ') : ''}\"#{rev.title}\" - #{rev.score}"
    end
  end
end