require 'awsraw/s3/signer'
require 'cgi'

module AWSRaw
  module S3

    # Generates the signed query string for an authenticated GET request to S3
    #
    # See http://docs.amazonwebservices.com/AmazonS3/latest/dev/RESTAuthentication.html#RESTAuthenticationQueryStringAuth
    class QueryStringSigner < Signer
      def query_string(bucket, object, expires, headers = {})
        query_string_hash(bucket, object, expires, headers).map { |k,v|
          "#{k}=#{v}"
        }.join("&")
      end

      def query_string_hash(bucket, object, expires, headers = {})
        string_to_sign = string_to_sign(bucket, object, expires, headers)
        signature = encoded_signature(string_to_sign)

        {
          "AWSAccessKeyId" => @access_key_id,
          "Expires"        => expires.to_s,
          "Signature"      => CGI.escape(signature)
        }
      end

      def string_to_sign(bucket, object, expires, headers = {})
        [
          "GET",
          headers["Content-MD5"]  || "",
          headers["Content-Type"] || "",
          expires.to_s,
          canonicalized_amz_headers(headers),
          canonicalized_resource(bucket, object)
        ].flatten.join("\n")
      end

    private

      # Assumes that bucket and object are already URI-encoded!
      def canonicalized_resource(bucket, object)
        "/#{bucket}/#{object}"
      end

    end

  end
end
