require 'awsraw/s3/canonicalized_resource'

module AWSRaw
  module S3

    module StringToSign

      # Generate the string to sign for authentication headers or query string signing, as per:
      #
      # http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html#ConstructingTheAuthenticationHeader
      #
      # Expects the following parameters:
      #
      #   :method         The HTTP method being used, e.g. GET, PUT, DELETE
      #   :uri            The full URI for the request, hostname and everything
      #   :content_md5    The Content-MD5 header; required if there is body content
      #   :content_type   The Content-Type header
      #   :date           The Date (or X-Amz-Date) header
      #   :amz_headers    A hash of all the X-Amz-* headers
      #
      # Headers in the :amz_headers hash that don't start with "X-Amz-" will be ignored.
      #
      # For query string signing, pass in the "Expires" timestamp in the :date parameter.
      def self.string_to_sign(request_info = {})
        [
          request_info[:method],
          request_info[:content_md5]  || "",
          request_info[:content_type] || "",
          request_info[:date],
          canonicalized_amz_headers(request_info[:amz_headers] || {}),
          CanonicalizedResource.canonicalized_resource(request_info[:uri])
        ].flatten.join("\n")
      end

      def self.canonicalized_amz_headers(headers)
        header_names = headers.keys.
          select  {|name| name =~ /^x-amz-/i }.
          sort_by {|name| name.downcase }

        header_names.map do |name|
          "#{name.downcase}:#{headers[name]}"
        end
      end

    end

  end
end

