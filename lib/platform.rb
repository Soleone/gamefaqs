# coupled to List
module GameFaqs
  class Platform
    attr_reader :name, :homepage, :id
    
    def initialize(params={})
      raise ArgumentError("Need at least the name, homepage, and id of the platform!") unless params[:name] && params[:homepage] && params[:id]
      @name = params[:name]
      @homepage = "#{GameFaqs::BASE_URL}#{params[:homepage]}"
      @id = params[:id] if params[:id]
    end
    
    def to_s
      @name
    end
    
    def self.all
      List.platforms
    end
  
    def self.all_ids
      List.platform_ids
    end
    
    def self.all_games
      List.games(self)
    end
    
    def find(game, refresh=false)
      Search.game(game, self, refresh)
    end
    
    # create case insensitive
    def self.find(platform_name)
      Search.platform(platform_name)
    end
      
  end
end