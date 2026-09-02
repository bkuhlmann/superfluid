# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "superfluid"
  spec.version = "0.1.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://alchemists.io/projects/superfluid"
  spec.summary = "Enhances Liquid with object composition and functional design."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/superfluid/issues",
    "changelog_uri" => "https://alchemists.io/projects/superfluid/versions",
    "homepage_uri" => "https://alchemists.io/projects/superfluid",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Superfluid",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/superfluid"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = ">= 4.0"

  spec.add_dependency "base64", "~> 0.3"
  spec.add_dependency "containable", "~> 2.5"
  spec.add_dependency "core", "~> 3.4"
  spec.add_dependency "functionable", "~> 1.4"
  spec.add_dependency "liquid", "~> 5.13"
  spec.add_dependency "refinements", "~> 14.0"
  spec.add_dependency "zeitwerk", "~> 2.8"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
