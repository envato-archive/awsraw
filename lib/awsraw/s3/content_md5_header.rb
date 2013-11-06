require 'digest/md5'

module AWSRaw
  module S3
    module ContentMD5Header

      def self.generate_content_md5(body)
        return nil if body.nil?

        digest = Digest::MD5.new
        if body.respond_to?(:read)
          read_file_into_digest(digest, body)
        else
          digest << body
        end

        digest.base64digest
      end

    private

      # This mimics the behaviour of Ruby's Digest::Instance#file method.
      # Unfortunately that takes a filename not a file, so we can't use it.
      def self.read_file_into_digest(digest, file)
        buffer = ""
        while file.read(16384, buffer)
          digest << buffer
        end
        file.rewind # ...so the HTTP client can read the body for sending.
      end

    end
  end
end
