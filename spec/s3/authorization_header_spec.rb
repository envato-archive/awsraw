require 'awsraw/s3/authorization_header'
require 'ostruct'

describe AWSRaw::S3::AuthorizationHeader do

  context ".authorization_header" do
    context "AWS example tests:" do
      # Examples are pulled from the AWS docs:
      # http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html

      let(:credentials) do
        OpenStruct.new(
          :access_key_id     => "AKIAIOSFODNN7EXAMPLE",
          :secret_access_key => "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
        )
      end

      def self.test_example(title, string_to_sign, signature)
        it "#{title} works" do
          header = described_class.authorization_header(string_to_sign, credentials)
          expect(header).to eq("AWS #{credentials.access_key_id}:#{signature}")
        end
      end

      test_example "Object GET",
        "GET\n\n\nTue, 27 Mar 2007 19:36:42 +0000\n/johnsmith/photos/puppy.jpg",
        "bWq2s1WEIj+Ydj0vQ697zp+IXMU="

      test_example "Object PUT",
        "PUT\n\nimage/jpeg\nTue, 27 Mar 2007 21:15:45 +0000\n/johnsmith/photos/puppy.jpg",
        "MyyxeRY7whkBe+bq8fHCL/2kKUg="

      test_example "List",
        "GET\n\n\nTue, 27 Mar 2007 19:42:41 +0000\n/johnsmith/",
        "htDYFYduRNen8P9ZfE/s9SuKy0U="

      test_example "Fetch",
        "GET\n\n\nTue, 27 Mar 2007 19:44:46 +0000\n/johnsmith/?acl",
        "c2WLPFtWHVgbEmeEG93a4cG37dM="

      test_example "Delete",
        "DELETE\n\n\nTue, 27 Mar 2007 21:20:26 +0000\n/johnsmith/photos/puppy.jpg",
        "lx3byBScXR6KzyMaifNkardMwNk="

      test_example "Upload",
        "PUT\n4gJE4saaMU4BqNR0kLY+lw==\napplication/x-download\nTue, 27 Mar 2007 21:06:08 +0000\nx-amz-acl:public-read\nx-amz-meta-checksumalgorithm:crc32\nx-amz-meta-filechecksum:0x02661779\nx-amz-meta-reviewedby:joe@johnsmith.net,jane@johnsmith.net\n/static.johnsmith.net/db-backup.dat.gz",
        "ilyl83RwaSoYIEdixDQcA4OnAnc="

      test_example "List All My Buckets",
        "GET\n\n\nWed, 28 Mar 2007 01:29:59 +0000\n/",
        "qGdzdERIC03wnaRNKh6OqZehG9s="

      test_example "Unicode Keys",
        "GET\n\n\nWed, 28 Mar 2007 01:49:49 +0000\n/dictionary/fran%C3%A7ais/pr%c3%a9f%c3%a8re",
        "DNEZGsoieTZ92F3bUfSPQcbGmlM="
    end
  end

end

