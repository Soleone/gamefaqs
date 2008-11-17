module GameFaqs
  class Question
    attr_reader :game, :id, :homepage, :title, :status, :replies, :type
    
    def initialize(game, id, options={})
      @game, @id = game, id
      @homepage = @game.homepage.gsub(/home/, "qna") << "?id=#{@id}"
      @title, @status, @replies, @type = options[:title], options[:status], options[:replies], options[:type]
    end
    
    def params(list=:all)
      case list
      when :all
        "type=-1"
      end
    end
  end
end