require 'net/http'
module AWSRaw
  module S3
    class HTTPRequestBuilder
      attr_reader :s3_request

      def initialize(s3_request)
        @s3_request = s3_request
      end

      def build
        klass = http_request_class(s3_request)
        path  = s3_request.uri.request_uri

        klass.new(path).tap do |http_request|
          s3_request.headers.each do |name, value|
            http_request[name] = value
          end
          set_content_on_request(http_request, s3_request.content)
        end
      end

      private

      def http_request_class(s3_request)
        case s3_request.method
          when "GET"
            Net::HTTP::Get
          when "HEAD"
            Net::HTTP::Head
          when "PUT"
            Net::HTTP::Put
          when "POST"
            Net::HTTP::Post
          else
            raise "Invalid HTTP method!"
        end
      end

      def set_content_on_request(http_request, content)
        if content.is_a?(File)
          http_request.body_stream = content
          http_request['Content-Length'] = content.size.to_s
        else
          http_request.body = content
        end
      end

    end
  end
end
