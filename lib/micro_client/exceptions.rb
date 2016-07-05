module MicroClient
  class Error < Exception ; end

  class InvalidResponse < Error
  end

  class InvalidMethodName < Error
  end

  class InvalidArguments < Error
  end

  class ConnectionError < Error
  end

  class ResponseError < Error
    attr_accessor :response

    def initialize(response:)
      @response = response
      super(response.to_s)
    end
  end

end
