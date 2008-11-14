require 'rubygems'
# gems
require 'hpricot'

require 'open-uri'
require 'date'

# load all source files
lib = %w[caching platform game search list review random]
lib.each { |file| require File.join(File.dirname(__FILE__), 'gamefaqs', file) }


module GameFaqs
  BASE_URL = "http://www.gamefaqs.com"
  SEARCH_URL = "#{BASE_URL}/search/index.html"

protected  
  def self.extract_id(url, with_html=true)
    url.match(/\/([\da-zA-Z]+)#{'\.html' if with_html}$/)
    $1
  end
  
  # 1. convert <br> to \n
  # 2. convert <b> to * (textile)
  # 3. convert <i> to _ (textile)
  # 4. strip all other tags
  def self.strip_html(string)
    string.gsub(/<br ?\/?>/, "\n").gsub(/<b>(.+)<\/b>/i, "*\\1*").gsub(/<i>(.+)<\/i>/i, "_\\1_").gsub(/<\/?(\d|\w)+>/i, "")
  end
  
  # Extract a table with a certain header from a html document
  # Yields 1) the Hpricot body element which usually contains a table
  # And 2) the heading of the table as a String
  def self.find_table(doc, header_regexp=/./, sub_path=nil)
    doc.search("//div.head/h1") do |h1|
      header = h1.inner_html

      if header =~ header_regexp
        body_path = "../../div.body#{'/'+sub_path if sub_path}"
        h1.search(body_path) do |body|
          yield body, header
        end
      end
    end
  end
  
end