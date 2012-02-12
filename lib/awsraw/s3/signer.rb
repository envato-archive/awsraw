require 'digest/sha1'
require 'openssl'
require 'uri'
require 'base64'

module AWSRaw
  module S3

    # Generates the Authorization header for a REST request to S3.
    #
    # See http://docs.amazonwebservices.com/AmazonS3/latest/dev/RESTAuthentication.html
    class Signer

      def initialize(access_key_id, secret_access_key)
        @access_key_id     = access_key_id
        @secret_access_key = secret_access_key
      end

      def signature(request)
        string_to_sign = string_to_sign(request)

        digest    = OpenSSL::Digest::Digest.new("sha1")
        sha       = OpenSSL::HMAC.digest(digest, @secret_access_key, string_to_sign)
        signature = Base64.encode64(sha).strip

        "AWS #{@access_key_id}:#{signature}"
      end

      def string_to_sign(request)
        [
          request.method,
          request.headers["Content-MD5"]  || "",
          request.headers["Content-Type"] || "",
          request.headers["Date"],
          canonicalized_amz_headers(request.headers),
          canonicalized_resource(request)
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

      def canonicalized_resource(request)
        # TODO: Should also append the sub-resource.
        request.path
      end

    end

  end
end
