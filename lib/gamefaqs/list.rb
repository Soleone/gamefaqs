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
    
      # find all games (very expensive)
      def games(platform, refresh=false)
        cached_value("games", []) do |games|
          letters = ('a'..'z').to_a << '0'
          letters.each do |letter|
            doc = Hpricot(open("#{platform.homepage}list_#{letter}.html"))
            doc.search(GAMES_PATH).each do |link|
              name = link.inner_html
              games << Game.new(name, platform, GameFaqs.extract_id(link['href']))
            end
          end
        end
      end
  
      def reviews(game, type=nil, refresh=false)
        reviews = cached_value("reviews-#{game.to_s}", [], refresh) do |reviews|
          url = game.homepage.sub(/\/home\//, "/review/")
          doc = Hpricot(open(url))
          doc.search("//div.head/h1") do |h1|
            header = h1.inner_html

            if header =~ /Reviews/
              h1.search("../../div.body/table/tr") do |tr|
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

      def faqs(game, type=nil, refresh=false)
        faqs = cached_value("faqs-#{game.to_s}", [], refresh) do |faqs|
          url = game.homepage.sub(/\/home\//, "/game/")
          doc = Hpricot(open(url))
          doc.search("//div.head/h1") do |h1|
            header = h1.inner_html

            h1.search("../../div.body/table/tr") do |tr|
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
      
    end # class < self
  end
end