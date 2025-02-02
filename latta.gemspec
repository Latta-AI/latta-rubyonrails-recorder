# frozen_string_literal: true

require_relative "lib/latta/version"

Gem::Specification.new do |spec|
  spec.name = "latta"
  spec.version = Latta::VERSION
  spec.authors = ["Latta AI s.r.o."]
  spec.email = ["info@latta.ai"]

  spec.summary = "Latta au"
  spec.description = "Latta ai"
  spec.homepage = "https://latta.ai"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"


  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_dependency "rails", ">= 5.2"
  spec.add_dependency "httparty"
  spec.add_dependency "sys-uname"
  spec.add_dependency "sys-cpu"
  spec.add_dependency "sys-memory"
  spec.add_dependency "iso-639"
end
