require 'awsraw/s3/configuration'

module AWSRaw
  module S3
    def configuration
      @configuration ||= self::Configuration.new
    end
    module_function :configuration

    def configure
      yield(configuration)
    end
    module_function :configure
  end
end