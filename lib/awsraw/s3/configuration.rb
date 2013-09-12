module AWSRaw
  module S3
    class Configuration
      attr_accessor :host, :regional_hosts

      def initialize
        @host = "s3.amazonaws.com"
        @regional_hosts = Hash.new { |hash, region| hash[region] = "s3-#{region}.amazonaws.com" }
      end
    end
  end
end