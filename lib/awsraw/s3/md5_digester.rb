module AWSRaw
  module S3
    class MD5Digester
      def initialize(string_or_file)
        @string_or_file = string_or_file
      end

      def digest
        if @string_or_file.is_a?(File)
          Digest::MD5.file(@string_or_file.path).digest
        elsif @string_or_file.is_a?(String)
          Digest::MD5.digest(@string_or_file)
        else
          raise "Unable to digest #{@string_or_file.class}"
        end
      end
    end
  end
end
