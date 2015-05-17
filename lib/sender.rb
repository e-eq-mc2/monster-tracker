module Ot::Sender
  class << self
    def method
      :post
    end

    def url
      'http://localhost:3000/monsters'
    end

    def send(path)
      payload = {
        multipart: true,
        monster: {
          image: File.new(path, 'rb')
        }
      }

      request = RestClient::Request.new(method: method, url: url, payload: payload)

      begin
        response = request.execute
      rescue => e
        puts "#{e}"
      end
    end
  end

end


