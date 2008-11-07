require 'rubygems'
# gems
require 'open-uri'
require 'hpricot'

# load all source files
lib = %w[cached_document platform game search review]
lib.each { |file| require File.join(File.dirname(__FILE__), 'lib', file) }


module GameFaqs
  BASE_URL = "http://www.gamefaqs.com"
  SEARCH_URL = "#{BASE_URL}/search/index.html"

protected  
  def self.extract_id(url)
    url.match(/\/([\da-zA-Z]+)\.html$/)
    $1
  end
end