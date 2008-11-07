class CachedDocument
  attr_accessor :url
  
  def initialize(url)
    @url = url
  end
  
  def reload!
    @doc = nil
  end
  
  def search(string)
    doc.search(string)
  end
  
private
  def doc
    @doc ||= Hpricot(open(@url))
  end
end