require 'awsraw/s3/string_to_sign'
require 'awsraw/s3/signature'

module AWSRaw
  module S3

    # Sign S3 URIs using the query string.
    #
    # See http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html#RESTAuthenticationQueryStringAuth
    class QueryStringSigner

      def initialize(credentials)
        @credentials = credentials
      end

      def sign(uri, expires)
        string_to_sign = StringToSign.string_to_sign(
          :method => "GET",
          :uri    => uri,
          :date   => expires.to_i
        )

        signature = Signature.signature(string_to_sign, @credentials)

        URI(uri).tap do |signed_uri|
          signed_uri.query = URI.encode_www_form(
            "AWSAccessKeyId" => @credentials.access_key_id,
            "Signature"      => signature,
            "Expires"        => expires.to_i
          )
        end
      end

      # For backwards-compatibility with pre-1.0 versions:
      alias_method :sign_with_query_string, :sign

    end
  end
end
