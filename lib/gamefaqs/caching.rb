module GameFaqs
  module Caching
    class Store < Hash
      attr_reader :keys
      
      def initialize(*args)
        super(*args)
        @keys = []
      end
      
      def []=(key, value)
        @keys << key
        clean!
        super
      end

      # retain only second half of cache if it gets to big
      def clean!
        if @keys.size > Cache.max_size
          @keys = @keys[(Cache.max_size/2)...@keys.size]
          reject! { |key, value| !@keys.include?(key) }
        end
      end
    end
      
    
    class Cache
      STORE = Store.new

      @@max_size = 100
      
      class << self
        def max_size=(size)
          @@max_size = size
        end
      
        def max_size
          @@max_size
        end

        def [](key)
          STORE[key]
        end
        alias :fetch :[]
        
        def []=(key, value)
          STORE[key] = value
        end
        
        def size
          STORE.size
        end
        
        def each(*args, &blk)
          STORE.each(*args, &blk)
        end
      end
    end

  protected
    # perform the block only when the name isn't filled already
    def cached_value(name, object=nil, force=false)
      if force || Cache.fetch(name).nil?
        Cache[name] = object
        return_value = yield object
        Cache[name] = return_value if object.nil?
      end
      Cache.fetch(name)
    end
  end
end