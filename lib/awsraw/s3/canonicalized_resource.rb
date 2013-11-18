require 'uri'
require 'cgi'

module AWSRaw
  module S3

    module CanonicalizedResource

      def self.canonicalized_resource(uri)
        uri = URI(uri)
        bucket = bucket_from_hostname(uri.hostname)

        [bucket && "/#{bucket}", uri.path, canonicalized_subresources(uri.query)].join
      end

      # Extract the bucket name from the hostname for virtual-host-style and
      # cname-style S3 requests. Returns nil for path-style requests.
      #
      # See: http://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html
      def self.bucket_from_hostname(hostname)
        if hostname =~ %r{s3[-\w\d]*\.amazonaws\.com$}
          components = hostname.split(".")
          if components.length > 3
            components[0..-4].join(".")
          else
            nil
          end
        else
          hostname
        end
      end

      VALID_SUBRESOURCES = %w{acl lifecycle location logging notification partNumber policy requestPayment torrent uploadId uploads versionId versioning versions website}

      # Generates the canonicalized subresources for a URI, as per:
      #
      # http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html
      #
      # Note: This is incomplete, in that it doesn't handle header values
      # that are overridden by parameters, nor does it handle the "delete"
      # parameter for multi-object Delete requests.
      def self.canonicalized_subresources(query)
        params = CGI.parse(query || "")
        subresources = params.keys & VALID_SUBRESOURCES
        return nil if subresources.empty?

        '?' + subresources.sort.collect { |subresource|
          if params[subresource].empty?
            subresource
          else
            params[subresource].collect { |value| "#{subresource}=#{value}" }
          end
        }.flatten.join('&')
      end

    end

  end
end
