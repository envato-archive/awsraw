require 'awsraw/s3/string_to_sign'

describe AWSRaw::S3::StringToSign do

  # Examples are pulled from the AWS docs: http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html

  it "Example Object GET" do
    request = {
      :method  => "GET",
      :bucket  => "johnsmith",
      :key     => "photos/puppy.jpg",
      :date    => "Tue, 27 Mar 2007 19:36:42 +0000"
    }

    expect(described_class.string_to_sign(request)).to eq(
      "GET\n\n\nTue, 27 Mar 2007 19:36:42 +0000\n/johnsmith/photos/puppy.jpg"
    )
  end

  it "Example Object PUT" do
    request = {
      :method       => "PUT",
      :bucket       => "johnsmith",
      :key          => "photos/puppy.jpg",
      :content_type => "image/jpeg",
      :date         => "Tue, 27 Mar 2007 21:15:45 +0000"
    }

    expect(described_class.string_to_sign(request)).to eq(
      "PUT\n\nimage/jpeg\nTue, 27 Mar 2007 21:15:45 +0000\n/johnsmith/photos/puppy.jpg"
    )
  end

  it "Example List" do
    request = {
      :method => "GET",
      :bucket => "johnsmith",
      :date   => "Tue, 27 Mar 2007 19:42:41 +0000"
    }

    expect(described_class.string_to_sign(request)).to eq(
      "GET\n\n\nTue, 27 Mar 2007 19:42:41 +0000\n/johnsmith/"
    )
  end

  it "Example Fetch" do
    request = {
      :method      => "GET",
      :bucket      => "johnsmith",
      :subresource => "acl",
      :date        => "Tue, 27 Mar 2007 19:44:46 +0000"
    }

    expect(described_class.string_to_sign(request)).to eq(
      "GET\n\n\nTue, 27 Mar 2007 19:44:46 +0000\n/johnsmith/?acl"
    )
  end

  it "Example Delete" do
    request = {
      :method => "DELETE",
      :bucket => "johnsmith",
      :key    => "photos/puppy.jpg",
      :date   => "Tue, 27 Mar 2007 21:20:26 +0000"
    }

    expect(described_class.string_to_sign(request)).to eq(
      "DELETE\n\n\nTue, 27 Mar 2007 21:20:26 +0000\n/johnsmith/photos/puppy.jpg"
    )
  end

  it "Example Upload" do
    request = {
      :method       => "PUT",
      :bucket       => "static.johnsmith.net",
      :key          => "db-backup.dat.gz",
      :date         => "Tue, 27 Mar 2007 21:06:08 +0000",
      :content_md5  => "4gJE4saaMU4BqNR0kLY+lw==",
      :content_type => "application/x-download",
      :amz_headers => {
        "x-amz-acl"                    => "public-read",
        "X-Amz-Meta-ReviewedBy"        => "joe@johnsmith.net,jane@johnsmith.net",
        "X-Amz-Meta-FileChecksum"      => "0x02661779",
        "X-Amz-Meta-ChecksumAlgorithm" => "crc32",
      }
    }

    expect(described_class.string_to_sign(request)).to eq(
      "PUT\n4gJE4saaMU4BqNR0kLY+lw==\napplication/x-download\nTue, 27 Mar 2007 21:06:08 +0000\nx-amz-acl:public-read\nx-amz-meta-checksumalgorithm:crc32\nx-amz-meta-filechecksum:0x02661779\nx-amz-meta-reviewedby:joe@johnsmith.net,jane@johnsmith.net\n/static.johnsmith.net/db-backup.dat.gz"
    )
  end

  it "Example List All My Buckets" do
    request = {
      :method => "GET",
      :date   => "Wed, 28 Mar 2007 01:29:59 +0000",
    }

    expect(described_class.string_to_sign(request)).to eq(
      "GET\n\n\nWed, 28 Mar 2007 01:29:59 +0000\n/"
    )
  end

  it "Example Unicode Keys" do
    request = {
      :method => "GET",
      :bucket => "dictionary",
      :key    => "fran%C3%A7ais/pr%c3%a9f%c3%a8re",
      :date   => "Wed, 28 Mar 2007 01:49:49 +0000"
    }

    expect(described_class.string_to_sign(request)).to eq(
      "GET\n\n\nWed, 28 Mar 2007 01:49:49 +0000\n/dictionary/fran%C3%A7ais/pr%c3%a9f%c3%a8re"
    )
  end

end


