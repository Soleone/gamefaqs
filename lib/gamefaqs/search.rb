module GameFaqs
  module Search
    extend Caching
    class SearchException < Exception; end

    class << self
      # Find a game by it's name on a certain platform (by name or Platform instance).
      # Per default it returns nil when no game could be found, or if there are multiple matches
      # Throws a detailed SearchError with help when no exact match is found (only when :whiny => true)
      def game(game_name, platform, options={:refresh => false, :whiny => false})
        cached_value("search-#{game_name}-#{platform}", nil, options[:refresh]) do
          platform = self.platform(platform) unless platform.is_a?(Platform)
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
            raise SearchException.new("Could not find a game containing the string \"#{game_name}\" on platform \"#{platform}\"!") if options[:whiny ]
            nil
          else
            raise SearchException.new("Found more than one game containing the string \"#{game_name}\": #{games.join(', ')}") if options[:whiny ]
            nil
          end
        end
      end
    
      # Find a platform by name
      # Per default it returns nil when no platform could be found, or if there are multiple matches
      # Throws a detailed SearchError with help when no exact match is found (only when :whiny => true)
      def platform(platform_name, options={:whiny => false})
        # get by full name (case insensitive)
        names = List.platforms.select { |p| p.name.downcase == platform_name.downcase }
        # find other similar if not found exactly one before
        names = List.platforms.select{|p| p.name =~ /#{platform_name.split(' ').join('.*')}/i} if names.size != 1
        # if still nothing it is probably if you searched for "n64".
        if names.size != 1
          platform_regexp = ""
          platform_name.each_byte { |byte| platform_regexp << byte.chr << ".*" }
          names = List.platforms.select{ |p| p.name =~ /#{platform_regexp}/i }
        end
        
        case names.size
        when 1
          names.first
        when 0
          raise SearchException.new("Could not find a platform containing the string \"#{platform_name}\"!") if options[:whiny]
          nil
        else
          raise SearchException.new("Found more than one platform containing the string \"#{platform_name}\": #{names.join(', ')}") if options[:whiny]
          nil
        end
      end
      
    private  
      def add_params(keywords, platform)
        "?game=#{keywords.gsub(/ /, '+')}" << "&platform=#{platform.id}"
      end
    end
  end
end