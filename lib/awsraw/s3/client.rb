require 'uri'
require 'faraday'
require 'awsraw/credentials'
require 'awsraw/s3/faraday_middleware'

module AWSRaw
  module S3

    # Legacy client, to support AWSRaw pre-1.0 requests. You shouldn't be using
    # this anymore.
    class Client

      def initialize(access_key_id, secret_access_key)
        @credentials = AWSRaw::Credentials.new(
          :access_key_id     => access_key_id,
          :secret_access_key => secret_access_key
        )
      end

      def request(params = {})
        host = params[:region] ? "s3-#{params[:region]}.amazonaws.com" : "s3.amazonaws.com"
        path = URI.escape("/#{params[:bucket]}#{params[:key]}")
        url = URI::HTTP.build(
          :host  => host,
          :path  => path,
          :query => params[:query]
        )

        faraday_response = connection.send(params[:method].downcase) do |request|
          request.url(url)
          request.headers = params[:headers] || {}
          request.body    = params[:content]
        end

        Response.new(
          :code    => faraday_response.status,
          :headers => faraday_response.headers,
          :content => faraday_response.body
        )
      end

      def request!(params = {})
        response = request(params)
        raise ConnectionError, response.inspect if response.failure?
      end

    private

      def connection
        @connection ||= Faraday.new do |faraday|
          faraday.use     AWSRaw::S3::FaradayMiddleware, @credentials
          faraday.adapter Faraday.default_adapter
        end
      end

    end

    class Response
      def initialize(params = {})
        @code    = params[:code]
        @headers = params[:headers]
        @content = params[:content]
      end

      attr_accessor :code
      attr_accessor :headers
      attr_accessor :content

      def success?
        code =~ /^2\d\d$/
      end

      def failure?
        !success?
      end
    end

  end
end
