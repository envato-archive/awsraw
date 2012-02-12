require 'awsraw/s3/signer'

describe AWSRaw::S3::Signer do
  let(:access_key_id)     { "0PN5J17HBGZHT7JJ3X82" }
  let(:secret_access_key) { "uV3F3YluFJax1cknvbcGwgjvx4QpvB+leU8dUj2o" }

  subject { AWSRaw::S3::Signer.new(access_key_id, secret_access_key) }

  context "examples from Amazon docs" do
    it "signs a get request correctly" do
      request = stub(
        :method  => "GET",
        :path    => "/johnsmith/photos/puppy.jpg",
        :headers => { "Date" => "Tue, 27 Mar 2007 19:36:42 +0000" }
      )

      subject.string_to_sign(request).should ==
        "GET\n\n\nTue, 27 Mar 2007 19:36:42 +0000\n/johnsmith/photos/puppy.jpg"

      subject.signature(request).should == "AWS #{access_key_id}:xXjDGYUmKxnwqr5KXNPGldn5LbA="
    end

    it "signs an upload correctly" do
      request = stub(
        :method => "PUT",
        :path   => "/static.johnsmith.net/db-backup.dat.gz",
        :headers => {
          "User-Agent"                   => "curl/7.15.5",
          "Date"                         => "Tue, 27 Mar 2007 21:06:08 +0000",
          "x-amz-acl"                    => "public-read",
          "Content-Type"                 => "application/x-download",
          "Content-MD5"                  => "4gJE4saaMU4BqNR0kLY+lw==",
          "X-Amz-Meta-ReviewedBy"        => "joe@johnsmith.net,jane@johnsmith.net",
          "X-Amz-Meta-FileChecksum"      => "0x02661779",
          "X-Amz-Meta-ChecksumAlgorithm" => "crc32",
          "Content-Disposition"          => "attachment; filename=database.dat",
          "Content-Encoding"             => "gzip",
          "Content-Length"               => "5913339"
        }
      )

      subject.string_to_sign(request).should ==
        "PUT\n4gJE4saaMU4BqNR0kLY+lw==\napplication/x-download\nTue, 27 Mar 2007 21:06:08 +0000\nx-amz-acl:public-read\nx-amz-meta-checksumalgorithm:crc32\nx-amz-meta-filechecksum:0x02661779\nx-amz-meta-reviewedby:joe@johnsmith.net,jane@johnsmith.net\n/static.johnsmith.net/db-backup.dat.gz"

      subject.signature(request).should == "AWS #{access_key_id}:C0FlOtU8Ylb9KDTpZqYkZPX91iI="
    end

  end
end
