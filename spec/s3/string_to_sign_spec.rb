require 'awsraw/s3/string_to_sign'

describe AWSRaw::S3::StringToSign do

  context ".string_to_sign" do
    context "AWS example tests:" do
      # Examples are pulled from the AWS docs:
      # http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html

      def self.test_example(title, request, string_to_sign)
        it "#{title} works" do
          expect(described_class.string_to_sign(request)).to eq(string_to_sign)
        end
      end

      test_example "Object GET",
        {
          :method  => "GET",
          :uri     => "http://johnsmith.s3.amazonaws.com/photos/puppy.jpg",
          :date    => "Tue, 27 Mar 2007 19:36:42 +0000"
        },
        "GET\n\n\nTue, 27 Mar 2007 19:36:42 +0000\n/johnsmith/photos/puppy.jpg"

      test_example "Object PUT",
        {
          :method       => "PUT",
          :uri          => "http://johnsmith.s3.amazonaws.com/photos/puppy.jpg",
          :content_type => "image/jpeg",
          :date         => "Tue, 27 Mar 2007 21:15:45 +0000"
        },
        "PUT\n\nimage/jpeg\nTue, 27 Mar 2007 21:15:45 +0000\n/johnsmith/photos/puppy.jpg"

      test_example "List",
        {
          :method => "GET",
          :uri    => "http://johnsmith.s3.amazonaws.com/?prefix=photos&max-keys=50&marker=puppy",
          :bucket => "johnsmith",
          :date   => "Tue, 27 Mar 2007 19:42:41 +0000"
        },
        "GET\n\n\nTue, 27 Mar 2007 19:42:41 +0000\n/johnsmith/"

      test_example "Fetch",
        {
          :method      => "GET",
          :uri         => "http://johnsmith.s3.amazonaws.com/?acl",
          :date        => "Tue, 27 Mar 2007 19:44:46 +0000"
        },
        "GET\n\n\nTue, 27 Mar 2007 19:44:46 +0000\n/johnsmith/?acl"

      test_example "Delete",
        {
          :method => "DELETE",
          :uri    => "http://s3.amazonaws.com/johnsmith/photos/puppy.jpg",
          :date   => "Tue, 27 Mar 2007 21:20:26 +0000"
        },
        "DELETE\n\n\nTue, 27 Mar 2007 21:20:26 +0000\n/johnsmith/photos/puppy.jpg"

      test_example "Upload",
        {
          :method       => "PUT",
          :uri          => "http://static.johnsmith.net:8080/db-backup.dat.gz",
          :date         => "Tue, 27 Mar 2007 21:06:08 +0000",
          :content_md5  => "4gJE4saaMU4BqNR0kLY+lw==",
          :content_type => "application/x-download",
          :amz_headers => {
            "x-amz-acl"                    => "public-read",
            "X-Amz-Meta-ReviewedBy"        => "joe@johnsmith.net,jane@johnsmith.net",
            "X-Amz-Meta-FileChecksum"      => "0x02661779",
            "X-Amz-Meta-ChecksumAlgorithm" => "crc32"
          }
        },
        "PUT\n4gJE4saaMU4BqNR0kLY+lw==\napplication/x-download\nTue, 27 Mar 2007 21:06:08 +0000\nx-amz-acl:public-read\nx-amz-meta-checksumalgorithm:crc32\nx-amz-meta-filechecksum:0x02661779\nx-amz-meta-reviewedby:joe@johnsmith.net,jane@johnsmith.net\n/static.johnsmith.net/db-backup.dat.gz"

      test_example "List All My Buckets",
        {
          :method => "GET",
          :uri    => "http://s3.amazonaws.com/",
          :date   => "Wed, 28 Mar 2007 01:29:59 +0000",
        },
        "GET\n\n\nWed, 28 Mar 2007 01:29:59 +0000\n/"

      test_example "Unicode Keys",
        {
          :method => "GET",
          :uri    => "http://s3.amazonaws.com/dictionary/fran%C3%A7ais/pr%c3%a9f%c3%a8re",
          :date   => "Wed, 28 Mar 2007 01:49:49 +0000"
        },
        "GET\n\n\nWed, 28 Mar 2007 01:49:49 +0000\n/dictionary/fran%C3%A7ais/pr%c3%a9f%c3%a8re"
    end
  end

end


