module MicroClient
  module HttpHelper
    extend ActiveSupport::Concern

    %w(get put patch post head delete).each do |meth|
      define_method meth do |url, params={}|
        type = %w(post patch put).include?(meth) ? :json : :params
        response = HTTP.send(meth, url, type => params)
        handle_response(response)
      end
    end

    def handle_response(response)
      if response.code <= 300
        parse_json response.to_s
      else
        raise ResponseError.new(response: response)
      end
    end

    def parse_json(json)
      begin
        Oj.load(json)
      rescue Oj::ParserError => e
        raise InvalidResponse.new(json << ' is not valid json')
      end
    end
  end
end
