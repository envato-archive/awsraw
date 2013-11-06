require 'awsraw/s3/signature'
require 'ostruct'
require 'json'

describe AWSRaw::S3::Signature do

  let(:credentials) do
    OpenStruct.new(
      :access_key_id     => "AKIAIOSFODNN7EXAMPLE",
      :secret_access_key => "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    )
  end

  context ".signature" do
    context "AWS example tests:" do
      # Examples are pulled from the AWS docs:
      # http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html

      def self.test_example(title, string_to_sign, signature)
        it "#{title} works" do
          header = described_class.signature(string_to_sign, credentials)
          expect(header).to eq(signature)
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

  context ".authorization_header" do
    it "structures the header correctly" do
      header = described_class.authorization_header("GET\n\n\nTue, 27 Mar 2007 19:36:42 +0000\n/johnsmith/photos/puppy.jpg", credentials)
      expect(header).to eq("AWS #{credentials.access_key_id}:bWq2s1WEIj+Ydj0vQ697zp+IXMU=")
    end
  end

  context "HTML form uploads" do
    # Example data taken from:
    # http://docs.aws.amazon.com/AmazonS3/latest/dev/HTTPPOSTExamples.html

    let(:policy_json) do
      <<EOF
{ "expiration": "2007-12-01T12:00:00.000Z",
  "conditions": [
    {"bucket": "johnsmith"},
    ["starts-with", "$key", "user/eric/"],
    {"acl": "public-read"},
    {"success_action_redirect": "http://johnsmith.s3.amazonaws.com/successful_upload.html"},
    ["starts-with", "$Content-Type", "image/"],
    {"x-amz-meta-uuid": "14365123651274"},
    ["starts-with", "$x-amz-meta-tag", ""]
  ]
}
EOF
    end

    let(:policy_base64) do
      "eyAiZXhwaXJhdGlvbiI6ICIyMDA3LTEyLTAxVDEyOjAwOjAwLjAwMFoiLAogICJjb25kaXRpb25zIjogWwogICAgeyJidWNrZXQiOiAiam9obnNtaXRoIn0sCiAgICBbInN0YXJ0cy13aXRoIiwgIiRrZXkiLCAidXNlci9lcmljLyJdLAogICAgeyJhY2wiOiAicHVibGljLXJlYWQifSwKICAgIHsic3VjY2Vzc19hY3Rpb25fcmVkaXJlY3QiOiAiaHR0cDovL2pvaG5zbWl0aC5zMy5hbWF6b25hd3MuY29tL3N1Y2Nlc3NmdWxfdXBsb2FkLmh0bWwifSwKICAgIFsic3RhcnRzLXdpdGgiLCAiJENvbnRlbnQtVHlwZSIsICJpbWFnZS8iXSwKICAgIHsieC1hbXotbWV0YS11dWlkIjogIjE0MzY1MTIzNjUxMjc0In0sCiAgICBbInN0YXJ0cy13aXRoIiwgIiR4LWFtei1tZXRhLXRhZyIsICIiXQogIF0KfQo="
    end

    let(:signature) { "0RavWzkygo6QX9caELEqKi9kDbU=" }

    it ".encode_form_policy correctly encodes a policy" do
      expect(subject.encode_form_policy(policy_json)).to eq(policy_base64)
    end

    # Note: This test fails. I'm pretty sure the example in the AWS docs is
    # wrong, but I'm leaving it failing until I can confirm that.
    it ".form_signature correctly signs a policy" do
      pending "Figure out which is wrong: the AWS examples or the code"
      expect(subject.form_signature(policy_base64, credentials)).to eq(signature)
    end

  end

end

