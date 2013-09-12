require 'awsraw/s3/configuration'

describe AWSRaw::S3::Configuration do
  subject(:configuration) { AWSRaw::S3::Configuration.new }

  it 'has the default S3 host' do
    expect(configuration.host).to eq 's3.amazonaws.com'
  end

  it 'has the default S3 regional host' do
    expect(configuration.regional_hosts['ap-southeast-2']).to eq 's3-ap-southeast-2.amazonaws.com'
  end

  describe 'with a custom regional hosts hash' do
    before do
      configuration.regional_hosts = { 'ap-southeast-2' =>  's3.envato.dev' }
    end

    it 'returns the custom regional host' do
      expect(configuration.regional_hosts['ap-southeast-2']).to eq 's3.envato.dev'
    end
  end
end