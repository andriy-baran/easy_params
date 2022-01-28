require_relative 'lib/easy_params/version'

Gem::Specification.new do |spec|
  spec.name          = 'easy_params'
  spec.version       = EasyParams::VERSION
  spec.authors       = ['Andrii Baran']
  spec.email         = ['andriy.baran.v@gmail.com']

  spec.summary       = %q{A tool that handles common tasks needed when working with params in Rails}
  spec.description   = %q{Dessribe structure, validate and coerce values. Powered by dry-types and dry-struct}
  spec.homepage      = 'https://github.com/andriy-baran/easy_params'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/andriy-baran/easy_params'
  # spec.metadata['changelog_uri'] = 'TODO: Put your gem's CHANGELOG.md URL here.'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  version_string = ['>= 3.2', '< 8']

  spec.add_runtime_dependency 'activemodel', version_string

  # spec.add_dependency 'dry-logic', '~> 0.4.2'
  spec.add_dependency 'dry-struct', '~> 1.4'
  spec.add_dependency 'dry-types', '~> 1.5'

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_vars_helper', '~> 0.1'
  spec.add_development_dependency 'simplecov', '~> 0.17'
end
