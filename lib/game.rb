module GameFaqs  
  class Game
    class GameException < Exception; end

    PATTERN = "//div.body/table/tr/td/a"

    attr_reviews :name, :platform, :homepage, :faqs, :codes
    
    def initialize(name, platform, id)
      @name = name
      @platform = Platform.create(platform)
      @id = id
      @homepage = "#{@platform.homepage}home/#{@id}.html"
      @reviews = []
      @faqs = []
      @codes = []
    end

    def name
      "#{@name} (#{@platform})"
    end
    
    def to_s
      "#{@name} [#{platform}]"
    end
    
    def reviews
      @reviews ||= Review.all_for_game(self)
    end
    
    class << self
      def all(platform)
        @@all ||= {}
        @@all[platform] ||= find_all_games(platform)
      end
    
      def all_names(platform)
        @@names ||= all(platform).keys
      end

      # find case insensitive
      def id_for(game_name, platform)
        all(platform)[all(platform).keys.select{|k| k.to_s.downcase == game_name.downcase}.first]
      end
      
      def create(game_name, platform)
        Game.new(all(platform).keys.select{|k| k.to_s.downcase == game_name.downcase}.first, platform)
      end
      
      def find(game_name, platform)
        platform = Platform.find(platform)
        names = all(platform).keys.select{|k| k.to_s.downcase =~ /#{game_name.downcase}/}
        case names.size
        when 1
          create(names.first, platform)
        when 0
          raise GameException.new("Could not find a #{platform} game containing the string \"#{game_name}\"!")
        else
          raise GameException.new("Found more than one #{platform} game containing the string \"#{game_name}\": #{names.join(', ')}")
        end
      end
      
    private
      def doc(platform, letter)
        @@doc ||= {}
        @@doc[platform] ||= {}
        @@doc[platform][letter] ||= Hpricot(open("#{Platform.create(platform).homepage}list_#{letter}.html"))
      end

      def find_all_games(platform)
        games = {}
        letters = ('a'..'z').to_a << '0'
        letters.each do |letter|
          doc(platform, letter).search(PATTERN).each do |link|
            link['href'].match(/\/(\d+)\.html/)
            games[link.inner_html] = $1
          end
        end
        games
      end
    end
    
  end
end