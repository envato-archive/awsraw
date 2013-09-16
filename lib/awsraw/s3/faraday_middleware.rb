require 'time'
require 'awsraw/s3/string_to_sign'
require 'awsraw/s3/authorization_header'

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
          :content_md5  => nil, # TODO: Handle content!
          :content_type => env[:request_headers]['Content-Type'],
          :date         => env[:request_headers]['Date'],
          :amz_headers  => env[:request_headers]
        )

        env[:request_headers]['Authorization'] = AuthorizationHeader.authorization_header(string_to_sign, @credentials)

        @app.call(env).on_complete do
          # do something with the response
        end
      end

    end
  end
end
