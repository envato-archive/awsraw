# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "awsraw/version"

Gem::Specification.new do |s|
  s.name        = "awsraw"
  s.version     = Awsraw::VERSION
  s.authors     = ["Pete Yandell", "David Goodlad"]
  s.email       = ["pete@notahat.com", "david@goodlad.net"]
  s.homepage    = "http://github.com/envato/awsraw"
  s.summary     = %q{Minimal AWS client}
  s.description = %q{A client for Amazon Web Services in the style of FlickRaw}

  s.rubyforge_project = "awsraw"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
