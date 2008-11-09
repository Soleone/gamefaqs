module GameFaqs
  class Review
    include Caching
    
    REVIEW_TYPES = [:detailed, :full, :quick]
    
    attr_reader :game, :id, :score, :author, :title, :type
    
    def initialize(options={})
      raise ArgumentError.new("Need at least the game and the review id") unless options[:game] && options[:id]
      @game, @id, @score, @author, @title, @type = options[:game], options[:id], options[:score], options[:author], options[:title], options[:type]
    end
    
    def to_s
      "#{@game}: #{@score} by #{author} (#{@title} [#{@type}])"
    end

    def score_to_i
      actual, max = @score.split("/")
      factor = 10 / max.to_i
      actual.to_i * factor
    end

    def text
      @text ||= parse_review[:text]
    end
    
    def created_at
      @created_at ||= Date.parse(parse_review[:created_at], "%m/%d/%y")
    end
    
    def self.all_for(game)
      List.reviews(game)
    end
    
    def self.review_type(string)
      REVIEW_TYPES.each do |type|
        return type if string =~ /#{type}/i
      end
    end 
    
  private
    def parse_review(refresh=false)
      cached_value("review-#{@id}-#{@game.platform}", {}, refresh) do |review|
        url = "#{@game.platform.homepage}review/#{@id}.html"
        doc = Hpricot(open(url))
        doc.search("//div.review/div.details") do |div|
          div.search("p:eq(0)") do |p|
            review[:text] = GameFaqs.strip_html(p.inner_html)
          end
          div.search("p:eq(1)") do |p|
            date = p.inner_html
            date.match(/Originally Posted:.*(\d\d\/\d\d\/\d?\d?\d\d)/)
            review[:created_at] = $1
          end
        end
      end
    end
  end
end