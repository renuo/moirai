# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "moirai"
  spec.version = "0.2.0"
  spec.authors = ["Alessandro Rodi", "Oliver Anthony", "Daniel Bengl"]
  spec.email = %w[alessandro.rodi@renuo.ch oliver.anthony@renuo.ch daniel.bengl@renuo.ch]

  spec.summary = "Manage translation strings in real time"
  spec.description = 'This gem allows you to manage translation strings in real time,
    viewing the live changes in the browser, with the changes then converted to a PR opened on the repository.'
  spec.homepage = "https://github.com/renuo/moirai"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/renuo/moirai"
  spec.metadata["changelog_uri"] = "https://github.com/renuo/moirai/CHANGELOG.md"
  spec.metadata["steep_types"] = "sig"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|docs)/}) || f.end_with?(".gem") }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7.0"
  spec.add_dependency "rails", ">= 6.1"

  spec.license = "MIT"
  spec.metadata["rubygems_mfa_required"] = "true"
end
