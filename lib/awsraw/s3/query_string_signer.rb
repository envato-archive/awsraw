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
      def sign_with_query_string(url, expires, headers = {})
        query_string_hash = query_string_hash(url, expires, headers)

        uri = URI.parse(url)
        uri.query = query_string_hash.map { |k,v| "#{k}=#{v}" }.join("&")
        uri.to_s
      end

      def query_string_hash(url, expires, headers = {})
        string_to_sign = string_to_sign(url, expires, headers)
        signature = encoded_signature(string_to_sign)

        {
          "AWSAccessKeyId" => @access_key_id,
          "Expires"        => expires.to_s,
          "Signature"      => CGI.escape(signature)
        }
      end

      def string_to_sign(url, expires, headers)
        [
          "GET",
          headers["Content-MD5"],
          headers["Content-Type"],
          expires.to_s,
          canonicalized_amz_headers(headers),
          canonicalized_resource(URI.parse(url))
        ].flatten.join("\n")
      end

    end

  end
end
