require 'digest/md5'
require 'time'
require 'uri'

module AWSRaw
  module S3

    US_STANDARD = "us-east-1"

    # Note that we use path style (rather than virtual hosted style) requests.
    # This is because virtual hosted requests only support lower case bucket
    # names.
    #
    # See http://docs.amazonwebservices.com/AmazonS3/latest/dev/VirtualHosting.html
    class Request
      def initialize(params, signer)
        @method  = params[:method]
        @bucket  = params[:bucket]
        @region  = params[:region]
        @key     = params[:key]
        @query   = params[:query]
        @headers = params[:headers] || {}
        @content = params[:content]

        raise "Content without Content-Type" if !@content.nil? && @headers["Content-Type"].nil?

        headers["Content-MD5"]   = content_md5 unless content.nil?
        headers["Date"]          = Time.now.rfc2822
        headers["Authorization"] = signer.signature(self)
      end

      attr_reader :method
      attr_reader :bucket
      attr_reader :key
      attr_reader :query
      attr_reader :headers
      attr_reader :content

      def host
        if @region && @region != US_STANDARD
          "s3-#{@region}.amazonaws.com"
        else
          "s3.amazonaws.com"
        end
      end

      def path
        @path ||= URI.escape("/" + [bucket, key].compact.join("/"))
      end


      def uri
        @uri ||= URI::HTTP.build(
          :host  => host,
          :path  => path,
          :query => query
        )
      end

      def content_md5
        @content_md5 ||= Base64.encode64(Digest::MD5.digest(content)).strip
      end
    end

  end
end
