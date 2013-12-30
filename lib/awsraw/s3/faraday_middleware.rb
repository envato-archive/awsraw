require 'time'
require 'faraday'
require 'awsraw/error'
require 'awsraw/s3/content_md5_header'
require 'awsraw/s3/signature'
require 'awsraw/s3/string_to_sign'

module AWSRaw
  module S3
    class FaradayMiddleware < Faraday::Middleware

      def initialize(app, credentials = nil)
        @app = app
        @credentials = credentials
      end

      def call(env)
        if env[:body] && env[:request_headers]['Content-Type'].nil?
          raise AWSRaw::Error, "Can't make a request with a body but no Content-Type header"
        end

        add_missing_headers(env)
        sign_request(env)

        @app.call(env)
      end

    private

      def add_missing_headers(env)
        env[:request_headers]['Date']        ||= Time.now.httpdate
        env[:request_headers]['Content-MD5'] ||= ContentMD5Header.generate_content_md5(env[:body]) if env[:body]
      end

      def sign_request(env)
        string_to_sign = StringToSign.string_to_sign(
          :method       => env[:method].to_s.upcase,
          :uri          => env[:url],
          :content_md5  => env[:request_headers]['Content-MD5'],
          :content_type => env[:request_headers]['Content-Type'],
          :date         => env[:request_headers]['Date'],
          :amz_headers  => env[:request_headers]
        )

        env[:request_headers]['Authorization'] = Signature.authorization_header(string_to_sign, @credentials)
      end

    end
  end
end
