require 'time'
require 'awsraw/s3/string_to_sign'
require 'awsraw/s3/authorization_header'

module AWSRaw
  module S3
    class FaradayRequestSigner
      def initialize(credentials)
        @credentials = credentials
      end

      def sign_request(request)
        # We need a date header to generate the signature.
        request.headers['Date'] ||= Time.now.httpdate

        string_to_sign = StringToSign.string_to_sign(
          :method       => request.method.to_s.upcase,
          :uri          => request.path,
          :content_md5  => nil, # TODO: Handle content!
          :content_type => request.headers['Content-Type'],
          :date         => request.headers['Date'],
          :amz_headers  => request.headers
        )

        request.headers['Authorization'] = AuthorizationHeader.authorization_header(string_to_sign, @credentials)
      end
    end
  end
end
