require 'net/http'
require 'awsraw/s3/request'
require 'awsraw/s3/response'
require 'awsraw/s3/signer'

module AWSRaw
  module S3

    # A client for the AWS S3 rest API.
    #
    # http://docs.amazonwebservices.com/AmazonS3/latest/API/APIRest.html
    class Client

      def initialize(access_key_id, secret_access_key)
        @access_key_id     = access_key_id
        @secret_access_key = secret_access_key
      end

      def request(params = {})
        request = Request.new(params, signer)

        http_request = construct_http_request(request)

        http_response = Net::HTTP.start(request.uri.host, request.uri.port) do |http|
          http.request(http_request)
        end

        construct_response(http_response)
      end

      def request!(params = {})
        response = request(params)
        raise "Uh oh! Failure from S3." if response.failure?
      end

    private

      def construct_http_request(request)
        klass = http_request_class(request)
        path  = request.uri.request_uri

        klass.new(path).tap do |http_request|
          request.headers.each do |name, value|
            http_request[name] = value
          end
          http_request.body = request.content
        end
      end

      def http_request_class(request)
        case request.method
          when "GET"
            Net::HTTP::Get
          when "HEAD"
            Net::HTTP::Head
          when "PUT"
            Net::HTTP::Put
          else
            raise "Invalid HTTP method!"
        end
      end

      def construct_response(http_response)
        Response.new(
          :code    => http_response.code,
          :headers => http_response.to_hash,
          :content => http_response.body
        )
      end

      def signer
        @signer ||= Signer.new(@access_key_id, @secret_access_key)
      end

    end

  end
end
