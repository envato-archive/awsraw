require 'net/http'
require 'awsraw/s3/request'
require 'awsraw/s3/http_request_builder'
require 'awsraw/s3/response'
require 'awsraw/s3/signer'
require 'awsraw/s3/md5_digester'
module AWSRaw
  module S3

    class ConnectionError < StandardError; end

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

        http_request = HTTPRequestBuilder.new(request).build

        http_response = Net::HTTP.start(request.uri.host, request.uri.port) do |http|
          http.request(http_request)
        end

        construct_response(http_response)
      end

      def request!(params = {})
        response = request(params)
        raise ConnectionError, response.inspect if response.failure?
      end

    private

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
