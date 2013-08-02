require 'digest/sha1'
require 'openssl'
require 'uri'
require 'base64'

module AWSRaw
  module S3


    # {:method=>:get, :body=>nil, :url=>#<URI::HTTP:0x007f7fca125588 URL:http://notahat.com/?cors>, :request_headers=>{"User-Agent"=>"Faraday v0.8.8"}, :parallel_manager=>nil, :request=>{:proxy=>nil}, :ssl=>{}}
   

    # Generates the Authorization header for a REST request to S3.
    #
    # See http://docs.amazonwebservices.com/AmazonS3/latest/dev/RESTAuthentication.html
    class Signer
      SUBRESOURCES = %w(acl lifecycle location logging notification partNumber policy requestPayment torrent uploadId uploads versionId versioning versions website)

      def initialize(access_key_id, secret_access_key)
        @access_key_id     = access_key_id
        @secret_access_key = secret_access_key
      end

      def authorization_header_value(request)
        string_to_sign = string_to_sign(request)
        signature = encoded_signature(string_to_sign)

        "AWS #{@access_key_id}:#{signature}"
      end

      # Backwards compatibility
      alias_method :signature, :authorization_header_value

      def encoded_signature(string_to_sign)
        digest    = OpenSSL::Digest::Digest.new("sha1")
        sha       = OpenSSL::HMAC.digest(digest, @secret_access_key, string_to_sign)
        signature = Base64.encode64(sha).strip
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
        if request.host =~ /^(.+)\.s3\.amazonaws\.com/
          bucket = request.host.split(/\./).first
          resource = '/' + bucket + request.path
        else
          resource = request.path
        end
        resource + canonicalized_subresource(request)
      end

      def canonicalized_subresource(request)
        return "" unless request.query
        subresources =
          request.query.split('&')
            .map { |s| s.split('=') }
            .select { |k,v| SUBRESOURCES.include? k }
            .map { |k,v| k + (v ? "=#{v}" : "") }
        if subresources.any?
          "?" + subresources.join("&")
        else
          ""
        end
      end

    end

  end
end
