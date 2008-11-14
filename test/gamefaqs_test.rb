require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/gamefaqs')

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
  
  # takes about a minute!
  
  #def test_list_all_games
  #  games = List.games("ds")
  #  assert games.size > 100
  #  assert games.first.is_a?(Game)
  #end
  
  def test_list_all_top_games
    games = List.top_games("pc")
    assert_equal 10, games.size
    assert games.first.is_a?(Game)
  end
  
  def list_games_by_genre
    games = List.games_by_genre("pc", "Action")
    assert games.size > 100
    assert games.first.is_a?(Game)
  end
end