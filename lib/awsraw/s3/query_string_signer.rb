require 'digest/sha1'
require 'openssl'
require 'uri'
require 'cgi'
require 'base64'

module AWSRaw
  module S3

    # Generates the signed query string for an authenticated GET request to S3
    #
    # See http://docs.amazonwebservices.com/AmazonS3/latest/dev/RESTAuthentication.html#RESTAuthenticationQueryStringAuth
    class QueryStringSigner

      def initialize(access_key_id, secret_access_key)
        @access_key_id     = access_key_id
        @secret_access_key = secret_access_key
      end

      def query_string(bucket, object, expires, headers = {})
        query_string_hash(bucket, object, expires, headers).map { |k,v|
          "#{k}=#{v}"
        }.join("&")
      end

      def query_string_hash(bucket, object, expires, headers = {})
        string_to_sign = string_to_sign(bucket, object, expires, headers)

        digest    = OpenSSL::Digest::Digest.new("sha1")
        sha       = OpenSSL::HMAC.digest(digest, @secret_access_key, string_to_sign)
        signature = Base64.encode64(sha).strip

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

      def canonicalized_amz_headers(headers)
        header_names = headers.keys.
          select  {|name| name =~ /^x-amz-/i }.
          sort_by {|name| name.downcase }

        header_names.map do |name|
          "#{name.downcase}:#{headers[name]}"
        end
      end

      # Assumes that bucket and object are already URI-encoded!
      def canonicalized_resource(bucket, object)
        "/#{bucket}/#{object}"
      end

    end

  end
end
