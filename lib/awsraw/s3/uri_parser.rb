# encoding: utf-8

require 'uri'

module AWSRaw
  module S3

    class URIParser
      def initialize(uri)
        @uri = URI(uri)
      end

      def bucket
        if path_style?
          @uri.path.split("/")[1]
        else
          @uri.hostname.split(".")[0]
        end
      end

      def path_style?
        @uri.hostname == "s3.amazonaws.com"
      end
    end

  end
end

