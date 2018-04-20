
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ssm_utils/version"

Gem::Specification.new do |spec|
  spec.name          = "ssm_utils"
  spec.version       = SsmUtils::VERSION
  spec.authors       = ["David Kolb"]
  spec.email         = ["david.kolb@krinchan.com"]

  spec.summary       = %q{Utility scripts for managing SSM params}
  spec.description   = %q{Provides some CLI interfaces into the SSM parameter store with opinions.}
  spec.homepage      = "https://github.com/ssm_utils"
  spec.license       = "MIT"

  spec.required_ruby_version = '~> 2.3'

  spec.files         = Dir['lib/**/*', 'exe/**/*']
  spec.bindir        = "exe"
  spec.executables   = ["manage_ssm_params"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.11.0"

  spec.add_dependency "paint", "~> 2"
  spec.add_dependency "commander", "~> 4"
  spec.add_dependency "aws-sdk-ssm", "~> 1"
end
