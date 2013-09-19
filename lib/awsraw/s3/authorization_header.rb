require 'digest/sha1'
require 'openssl'
require 'base64'

module AWSRaw
  module S3

    module AuthorizationHeader

      # Given a string to sign and some AWS credentials, generate a value
      # for the Authorization header of an S3 request.
      def self.authorization_header(string_to_sign, credentials)
        "AWS #{credentials.access_key_id}:#{signature(string_to_sign, credentials)}"
      end

      def self.signature(string_to_sign, credentials)
        digest    = OpenSSL::Digest::Digest.new("sha1")
        sha       = OpenSSL::HMAC.digest(digest, credentials.secret_access_key, string_to_sign)
        Base64.encode64(sha).strip
      end

    end

  end
end
