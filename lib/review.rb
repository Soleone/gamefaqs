module GameFaqs
  class Review
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
    
    def self.all_for_game(game)
      url = game.homepage.sub(/\/home\//, "/review/")
      doc = Hpricot(open(url))
      reviews = []
      doc.search("//div.head/h1") do |h1|
        header = h1.inner_html

        if header =~ /Reviews/
          h1.search("../../div.body/table/tr") do |tr|
            review = {}
            review[:type] = review_type(header)
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
      reviews
    end
    
    def self.average_score(game)
      reviews = all_for_game(game)
      sum = reviews.map{|r| r.score_to_i}.inject{|memo, score| memo + score}
      sum / reviews.size.to_f
    end
    
    def self.review_type(string)
      case string
      when /Detailed/
        :detailed
      when /Full/
        :full
      when /Quick/
        :quick
      end
    end
  end
end