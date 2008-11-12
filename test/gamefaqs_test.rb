require 'test/unit'
require '../lib/gamefaqs'

class GameFaqsTest < Test::Unit::TestCase
  include GameFaqs

  def setup
    @game ||= Search.game("gothic ii", "pc")    
  end
  
  def test_all_platforms_available
    assert Platform.all.size > 0
    assert Platform.all.first.is_a?(Platform)
  end
  
  def test_search_for_game
    game = Search.game("Castlevania Order", "ds")
    assert game.is_a?(Game)
    assert game.name =~ /castlevania.*order/i
    assert game.platform.is_a?(Platform)
    assert_equal "DS", game.platform.name
  end
  
  def test_game_reviews_available
    reviews = Review.all_for(@game)
    assert reviews.size > 0
    assert reviews.first.is_a?(Review)
  end
  
  def test_average_score_available
    assert @game.average_score <= 10
  end
  
  def test_review_score_available
    assert @game.reviews.first.score[/(\d\d?)\/\d\d/]
    assert_equal $1.to_i, @game.reviews.first.score_to_i
  end
end