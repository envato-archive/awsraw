require 'digest/sha1'
require 'openssl'
require 'base64'

module AWSRaw
  module S3

    module Signature

      # Given a string to sign and some AWS credentials, generate a signature
      # for an S3 request.
      def self.signature(string_to_sign, credentials)
        base64_encode(hmac_sha1(string_to_sign, credentials))
      end

      # Given a string to sign and some AWS credentials, generate a value
      # for the Authorization header of an S3 request.
      def self.authorization_header(string_to_sign, credentials)
        "AWS #{credentials.access_key_id}:#{signature(string_to_sign, credentials)}"
      end

      # Encode a HTML form upload policy. See:
      # http://docs.aws.amazon.com/AmazonS3/latest/dev/HTTPPOSTForms.html
      #
      # The policy is expected to be a JSON document.
      def self.encode_form_policy(policy)
        base64_encode(policy)
      end

      # Sign a policy document for a HTML form upload.
      #
      # The policy document is expected to be base64 encoded JSON.
      # See the .encode_form_policy method.
      def self.form_signature(policy_base64, credentials)
        signature(policy_base64, credentials)
      end

    private

      def self.hmac_sha1(data, credentials)
        digest = OpenSSL::Digest::Digest.new("sha1")
        OpenSSL::HMAC.digest(digest, credentials.secret_access_key, data)
      end

      def self.base64_encode(data)
        Base64.encode64(data).tr("\n", "")
      end

    end

  end
end
