module GameFaqs
  module Search
    class << self  
      def game(game_name, platform)
        doc = Hpricot(open("#{SEARCH_URL}#{add_params(game_name, platform)}"))
        doc.search("//div.head/h1") do |h1|
          if h1.inner_html =~ /Best Matches/
            h1.search("../../div.body/table") do |table|
              table.search("tr/td/a") do |a|
                if a.inner_html =~ /#{game_name.split(' ').join('.*')}/i
                  return Game.new(a.inner_html.strip, platform, GameFaqs.extract_id(a['href']))
                end
              end
            end
          end
        end
      end
    
    private  
      def add_params(keywords, platform)
        "?game=#{keywords.gsub(/ /, '+')}" << "&platform=#{Platform.find(platform).id}"
      end
    end
  end
end