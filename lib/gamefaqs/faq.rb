module GameFaqs
  class FAQ
    attr_reader :game, :id, :type, :title, :created_at, :author, :version, :size
    
    def initialize(options={})
      raise ArgumentError.new("Need at least the game and the faq id") unless options[:game] && options[:id]
      @game, @id, @type, @title, @created_at, @author, @version, @size = options[:game], options[:id], options[:type], options[:title], options[:created_at], options[:author], options[:size]
    end
    
    def homepage(refresh=false)
      cached_value("review-#{@id}-#{@game}", [], refresh) do |homepage|
        url = "#{@game.homepage.gsub(/game/, 'file').gsub('.html', '')}/#{@id}"
        doc = Hpricot(open(url))
        doc.search("a[text()='View/Download Original File'") do |a|
          puts a.inner_html
          puts a['href']
          homepage << a['href']
        end
      end.first      
    end
    
  end
end