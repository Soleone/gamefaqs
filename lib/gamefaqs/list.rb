module GameFaqs
  module List
    extend Caching
    
    PLATFORMS_PATH    = "//ul.systems/li/a"
    PLATFORMS_ID_PATH = "//form#search/select[@name=platform]/option"
    GAMES_PATH        = "//div.body/table/tr/td/a"

    class << self
      def platforms(refresh=false)
        cached_value("platforms", [], refresh) do |platforms|
          systems_doc = Hpricot(open("#{GameFaqs::BASE_URL}/systems.html"))
          systems_doc.search(PLATFORMS_PATH).each do |link|
            name = link.inner_html
            platforms << Platform.new({:name => name, :homepage => link['href'], :id => platform_ids[name]})
          end
        end
      end
    
      # find all games (very expensive, takes nearly a minute, because of 27 html requests and resulting parsing)
      def games(platform, refresh=false)
        platform = Platform.find(platform) unless platform.is_a?(Platform)
        cached_value("games-#{platform}", []) do |games|
          letters = ('a'..'z').to_a << '0'
          letters.each do |letter|
            doc = Hpricot(open("#{platform.homepage}list_#{letter}.html"))
            insert_games_to_array(games, doc, platform, /Games by/)
          end
        end
      end
  
      def games_by_genre(platform, genre, refresh=false)
        platform = Platform.find(platform) unless platform.is_a?(Platform)
        cached_value("games_by_#{genre}-#{platform}", []) do |games|
          doc = Hpricot(open("#{platform.homepage}cat_#{Game.GENRES[genre]}.html"))
          insert_games_to_array(games, doc, platform, /Games by Category/)
        end
      end
      
      def top_games(platform, refresh=false)
        platform = Platform.find(platform) unless platform.is_a?(Platform)
        cached_value("top_games-#{platform}", []) do |games|
          doc = Hpricot(open(platform.homepage))
          insert_games_to_array(games, doc, platform, /Top 10 Games/, "ul/li/a")
        end
      end
      
      def reviews(game, type=nil, refresh=false)
        reviews = cached_value("reviews-#{game.to_s}", [], refresh) do |reviews|
          url = game.homepage.sub(/\/home\//, "/review/")
          doc = Hpricot(open(url))
          GameFaqs.find_table(doc, /Reviews/, "table/tr") do |tr, header|
            review = {}
            review[:type] = Review.review_type(header)
            tr.search("td:eq(0)") do |td|
              td.search("a") do |a|
                review[:id] = GameFaqs.extract_id(a['href'])
                review[:title] = a.inner_html.strip
              end
            end
            tr.search("td:eq(1)") do |td|
              td.search("a") do |a|
                review[:author] = a.inner_html.strip
              end
            end
            tr.search("td:eq(2)") do |td|
              review[:score] = td.inner_html.strip
            end
            review[:game] = game   
            reviews << Review.new(review)
          end
        end
        if type
          types = Review::REVIEW_TYPES
          raise ArgumentError.new("Type must be one of #{types.join(', ')}") unless types.include?(type.to_sym)
          reviews.reject { |review| review.type != type.to_sym}
        else
          reviews
        end
      end

      def questions(game, refresh=false)
        questions = cached_value("questions-#{game.to_s}", [], refresh) do |questions|
          url = game.homepage.sub(/\/home\//, "/qna/") << "?type=-1"
          doc = Hpricot(open(url))
          GameFaqs.find_table(doc, /Help$/, "table/tr") do |tr, header|
            question = {}
            question[:type] = header
            tr.search("td:eq(0)") do |td|
              td.search("a") do |a|
                question[:id] = GameFaqs.extract_question_id(a['href'])
                question[:title] = a.inner_html.strip
              end
            end
            tr.search("td:eq(1)") do |td|
              question[:status] = td.inner_html
            end
            tr.search("td:eq(2)") do |td|
              question[:replies] = td.inner_html
            end
            questions << Question.new(game, question[:id], question)
          end
        end
      end
      
      def faqs(game, type=nil, refresh=false)
        faqs = cached_value("faqs-#{game.to_s}", [], refresh) do |faqs|
          url = game.homepage.sub(/\/home\//, "/game/")
          doc = Hpricot(open(url))
          GameFaqs.find_table(doc, /./, "table/tr") do |tr, header|
            faq = {}
            faq[:type] = header
            tr.search("td:eq(0)") do |td|
              td.search("a") do |a|
                review[:id] = GameFaqs.extract_id(a['href'])
                review[:title] = a.inner_html.strip
              end
            end
            tr.search("td:eq(1)") do |td|
              td.search("a") do |a|
                review[:author] = a.inner_html.strip
              end
            end
            tr.search("td:eq(2)") do |td|
              review[:score] = td.inner_html.strip
            end
            review[:game] = game   
            reviews << Review.new(review)
          end
        end
        if type
          types = FAQ::FAQ_TYPES
          raise ArgumentError.new("Type must be one of #{types.join(', ')}") unless types.include?(type.to_sym)
          faqs.reject { |faq| faq.type != type.to_sym}
        else
          faqs
        end
      end

      # find all IDs for every platform (cached, do only once)
      def platform_ids(refresh=false)
        cached_value("game_ids", {}, refresh) do |ids|
          search_doc = Hpricot(open(SEARCH_URL))
          search_doc.search(PLATFORMS_ID_PATH).each do |option|
            ids[option['label']] = option['value']
          end
        end
      end
    
    private
      # Will add all games found within the +doc+ to the specfied +array+
      # Search in a table with the header +header_regexp+ and the specified +sub_path+
      def insert_games_to_array(array, doc, platform, header_regexp, sub_path="table/tr/td:eq(0)/a")
        GameFaqs.find_table(doc, header_regexp, sub_path) do |link, header|
          name = link.inner_html
          array << Game.new(name, platform, GameFaqs.extract_id(link['href']))
        end
      end  
    
    end # class < self
  end
end