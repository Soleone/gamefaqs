module GameFaqs
  module Caching
    
  protected
    # perform the block only when the name isn't filled already
    def cached_value(name, object=nil, force=false)
      @@cache ||= {}
      if force || @@cache[name].nil?
        @@cache[name] = object
        return_value = yield object
        @@cache[name] = return_value if object.nil?
      end
      @@cache[name] 
    end
  end
end