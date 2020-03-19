
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trello_radiator/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'trello_radiator'
  spec.version       = TrelloRadiator::VERSION
  spec.authors       = ['Clayto']
  spec.email         = ['sealz@users.noreply.github.com']

  spec.summary       = 'An information radiator for Trello.'
  spec.description   = 'Collects metrics from Trello and helps inform ' \
                       'stakeholders so that they can make better decisions.'
  spec.homepage      = 'https://github.com/lighthauz/trello_radiator'
  spec.license       = 'Nonstandard'

  # Prevent pushing this gem to RubyGems.org.
  # To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this
  # section to allow pushing to any host.

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://trusona.jfrog.io/trusona/api/gems/trusona-rubygems'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'httparty', '~> 0.16'

  spec.add_development_dependency 'bump', '~> 0.5'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'dotenv', '~> 2.2'
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'guard-rubocop', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.49'
  spec.add_development_dependency 'simplecov', '~> 0.14'
end
