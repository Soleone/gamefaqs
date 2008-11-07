require 'test/unit'
require '../game_faqs'

class GameFaqsTest < Test::Unit::TestCase
  include GameFaqs
  
  def test_all_platforms
  #  assert Platform.all.first.is_a?(Platform)
  end
  
  def test_search_for_game
    game = Search.game("Castlevania Order", "ds")
    assert game.is_a?(Game)
    assert game.name =~ /castlevania.*order/i
    assert game.platform.is_a?(Platform)
    assert_equal "DS", game.platform.name
  end
  
  def test_game_reviews_count
    game = Search.game("Castlevania Order", "ds")
    reviews = Review.all_for_game(game)
    #reviews.each { |r| puts r }
  end
  
  def test_average_score
    game = Search.game("gothic ii", "pc")
    puts Review.average_score(game)
  end
end