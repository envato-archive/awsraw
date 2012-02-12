module AWSRaw
  module S3

    class Response
      def initialize(params = {})
        @code    = params[:code]
        @headers = params[:headers]
        @content = params[:content]
      end

      attr_accessor :code
      attr_accessor :headers
      attr_accessor :content

      def success?
        code =~ /^2\d\d$/
      end

      def failure?
        !success?
      end
    end

  end
end

