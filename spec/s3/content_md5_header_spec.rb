require 'stringio'
require 'awsraw/s3/content_md5_header'

describe AWSRaw::S3::ContentMD5Header do

  context ".generate_content_md5" do
    it "returns nil if the body is nil" do
      expect(subject.generate_content_md5(nil)).to be_nil
    end

    it "generates the correct digest for a string" do
      expect(subject.generate_content_md5("rhubarb")).to eq("lBxzvNO0KqwdCwPVMx2IYQ==")
    end

    it "generates the correct digest for a file" do
      file = StringIO.new("rhubarb")
      expect(subject.generate_content_md5(file)).to eq("lBxzvNO0KqwdCwPVMx2IYQ==")
    end

    it "rewinds a file after reading it" do
      file = StringIO.new("rhubarb")
      subject.generate_content_md5(file)
      expect(file.pos).to eq(0)
    end
  end

end
