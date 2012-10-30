require 'awsraw/s3/signer'
require 'cgi'

module AWSRaw
  module S3

    # Generates a signed query string to make an authenticated S3 GET request
    #
    # See http://docs.amazonwebservices.com/AmazonS3/latest/dev/RESTAuthentication.html#RESTAuthenticationQueryStringAuth
    #
    # The Authorization header method is usually preferable, as implemented in
    # AWSRaw::S3::Signer. However, you may have occasions where you need a
    # simple "download URL", without having to tell your user-agent (browser,
    # curl, wget, etc) about all the special AWS headers. The query string
    # authentication method is useful in those cases.
    class QueryStringSigner < Signer
      def query_string(url, expires)
        query_string_hash(url, expires).map { |k,v|
          "#{k}=#{v}"
        }.join("&")
      end

      def query_string_hash(url, expires)
        string_to_sign = string_to_sign(url, expires)
        signature = encoded_signature(string_to_sign)

        {
          "AWSAccessKeyId" => @access_key_id,
          "Expires"        => expires.to_s,
          "Signature"      => CGI.escape(signature)
        }
      end

      def string_to_sign(url, expires)
        [
          "GET",
          # Assume user-agent won't send Content-MD5 header
          "",
          # Assume user-agent won't send Content-Type header
          "",
          expires.to_s,
          # Assume user-agent won't send any amz headers
          canonicalized_amz_headers({}),
          canonicalized_resource(URI.parse(url))
        ].flatten.join("\n")
      end

    end

  end
end
