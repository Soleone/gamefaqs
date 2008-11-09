module GameFaqs
  module Search
    extend Caching
    class SearchException < Exception; end

    # throws a SearchError when no exact match is found
    def self.game(game_name, platform, refresh=false)
      cached_value("search-#{game_name}-#{platform}", nil, refresh) do
        platform = Platform.find(platform) unless platform.is_a?(Platform)
        games = []
        doc = Hpricot(open("#{SEARCH_URL}#{add_params(game_name, platform)}"))
        doc.search("//div.head/h1") do |h1|
          if h1.inner_html =~ /Best Matches/
            h1.search("../../div.body/table") do |table|
              table.search("tr/td/a") do |a|
                if a.inner_html =~ /#{game_name.split(' ').join('.*')}/i
                  games << Game.new(a.inner_html.strip, platform, GameFaqs.extract_id(a['href']))
                end
              end
            end
          end
        end
        
        case games.size
        when 1
          games.first
        when 0
          raise SearchException.new("Could not find a game containing the string \"#{game_name}\" on platform \"#{platform}\"!")
        else
          raise SearchException.new("Found more than one game containing the string \"#{game_name}\": #{games.join(', ')}")
        end
      end
    end
    
    class << self  
      
      def platform(platform_name)
        # get by full name (case insensitive)
        names = List.platforms.select { |p| p.name.downcase == platform_name.downcase }
        # find other similar if not found exactly one before
        if names.size != 1
          names = List.platforms.select{|p| p.name.downcase =~ /#{platform_name.split(' ').join('.*')}/i}
        end

        case names.size
        when 1
          names.first
        when 0
          raise SearchException.new("Could not find a platform containing the string \"#{platform_name}\"!")
        else
          raise SearchException.new("Found more than one platform containing the string \"#{platform_name}\": #{names.join(', ')}")
        end
      end
      
    private  
      def add_params(keywords, platform)
        "?game=#{keywords.gsub(/ /, '+')}" << "&platform=#{platform.id}"
      end
    end
  end
end