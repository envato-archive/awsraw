

module StringToSign
  def self.string_to_sign(request_info = {})
    [
      request_info[:method],
      request_info[:content_md5]  || "",
      request_info[:content_type] || "",
      request_info[:date],
      canonicalized_amz_headers(request_info[:amz_headers] || {}),
      canonicalized_resource(request_info[:bucket], request_info[:key], request_info[:subresource])
    ].flatten.join("\n")
  end

private

  def self.canonicalized_amz_headers(headers)
    header_names = headers.keys.
      select  {|name| name =~ /^x-amz-/i }.
      sort_by {|name| name.downcase }

    header_names.map do |name|
      "#{name.downcase}:#{headers[name]}"
    end
  end

  def self.canonicalized_resource(bucket, key, subresource = nil)
    "/#{bucket}/#{key}".tap do |resource|
      resource << "?#{subresource}" if subresource
    end
  end
end


describe StringToSign do

  context "examples from Amazon docs" do
    it "generates the right string to sign for a get request" do
      request = {
        :method  => "GET",
        :host    => "s3.amazonaws.com",
        :bucket  => "johnsmith",
        :key     => "photos/puppy.jpg",
        :date    => "Tue, 27 Mar 2007 19:36:42 +0000"
      }

      expect(described_class.string_to_sign(request)).to eq("GET\n\n\nTue, 27 Mar 2007 19:36:42 +0000\n/johnsmith/photos/puppy.jpg")
    end

    it "generates the right string to sign for an upload" do
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
  end

end


