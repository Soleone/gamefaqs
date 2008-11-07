module GameFaqs
  class Platform
    class PlatformException < Exception; end
    
    BASE_URL = "/systems.html"
    
    PATTERN = "//ul.systems/li/a"
    ID_PATTERN = "//form#search/select[@name=platform]/option"
    
    attr_reader :name, :homepage, :id
    
    def initialize(name)
      @name = name
      @homepage = "#{GameFaqs::BASE_URL}#{Platform.url_for(@name)}"
      @id = Platform.all_ids[@name]
    end
    
    def to_s
      @name
    end
    
    class << self
      def all
        @@all ||= find_all_platforms
      end
    
      def all_names
        @@names ||= all.keys
      end

      def all_ids
        @@ids ||= find_all_ids
      end
      
      # find case insensitive
      def url_for(platform_name)
        all[platform_name]
      end
      
      def id_for(platform_name)
        all_ids[platform_name]
      end
      
      def create(platform_name)
        Platform.new(all.keys.select{|k| k.to_s.downcase == platform_name.downcase}.first)
      end
      
      def find(platform_name)
        # get by full name (case insensitive)
        names = all.keys.select { |k| k.to_s.downcase == platform_name.downcase }
        # find other similar if not found exactly one before
        if names.size != 1
          names = all.keys.select{|k| k.to_s.downcase =~ /#{platform_name.split(' ').join('.*')}/i}
        end

        case names.size
        when 1
          create(names.first)
        when 0
          raise PlatformException.new("Could not find a platform containing the string \"#{platform_name}\"!")
        else
          raise PlatformException.new("Found more than one platform containing the string \"#{platform_name}\": #{names.join(', ')}")
        end
      end
      
    private
      def doc
        @@doc ||= CachedDocument.new("#{GameFaqs::BASE_URL}#{BASE_URL}")
      end
      
      def doc_search
        @@doc_search ||= Hpricot(open(SEARCH_URL))
      end
   
      def find_all_platforms
        platforms = {}
        doc.search(PATTERN).each do |link|
          platforms[link.inner_html] = link['href']
        end
        platforms
      end
      
      def find_all_ids
        ids = {}
        doc_search.search(ID_PATTERN).each do |option|
          ids[option['label']] = option['value']
        end
        ids
      end
    end
  end
end