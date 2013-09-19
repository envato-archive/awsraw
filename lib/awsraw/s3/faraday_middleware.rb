require 'time'
require 'faraday'
require 'awsraw/s3/string_to_sign'
require 'awsraw/s3/signature'

module AWSRaw
  module S3
    class FaradayMiddleware < Faraday::Middleware

      def initialize(app, credentials = nil)
        @app = app
        @credentials = credentials
      end

      def call(env)
        env[:request_headers]['Date'] ||= Time.now.httpdate

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
