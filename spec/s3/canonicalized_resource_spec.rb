require 'awsraw/s3/canonicalized_resource'

describe AWSRaw::S3::CanonicalizedResource do

  context ".canonicalized_resource" do
    it "works for a virtual-host-style request" do
      expect(subject.canonicalized_resource("http://johnsmith.s3.amazonaws.com/puppies.jpg")).to eq("/johnsmith/puppies.jpg")
    end

    it "works for a path-style request" do
      expect(subject.canonicalized_resource("http://s3.amazonaws.com/johnsmith/puppies.jpg")).to eq("/johnsmith/puppies.jpg")
    end
  end

  context ".bucket_from_hostname" do
    it "gets the bucket from virtual-host-style requests in the default region" do
      expect(subject.bucket_from_hostname("johnsmith.net.s3.amazonaws.com")).to eq("johnsmith.net")
    end

    it "gets the bucket from virtual-host-style requests in other regions" do
      expect(subject.bucket_from_hostname("johnsmith.net.s3-eu-west-1.amazonaws.com")).to eq("johnsmith.net")
    end

    it "gets the bucket from cname-style requests" do
      expect(subject.bucket_from_hostname("johnsmith.net")).to eq("johnsmith.net")
    end

    it "doesn't get the bucket for path-style requests in the default region" do
      expect(subject.bucket_from_hostname("s3.amazonaws.com")).to be_nil
    end

    it "doesn't get the bucket for path-style requests in other regions" do
      expect(subject.bucket_from_hostname("s3-eu-west-1.amazonaws.com")).to be_nil
    end
  end

  context ".canonicalized_subresources" do
    it "includes valid subresources" do
      expect(subject.canonicalized_subresources("acl")).to eq("?acl")
    end

    it "excludes invalid subresources" do
      expect(subject.canonicalized_subresources("rhubarb")).to be_nil
    end

    it "sorts the subresources" do
      expect(subject.canonicalized_subresources("website&acl")).to eq("?acl&website")
    end

    it "includes subresources with parameters" do
      expect(subject.canonicalized_subresources("uploadId=foo")).to eq("?uploadId=foo")
    end
  end

end
