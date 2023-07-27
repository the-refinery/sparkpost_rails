# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)

require 'sparkpost_rails/version'

Gem::Specification.new do |s|
  s.name        = 'sparkpost_rails'
  s.version     = SparkPostRails::VERSION
  s.authors     = ['Kevin Kimball', 'Dave Goerlich', 'Manuel Schönlaub']
  s.email       = %w[kwkimball@gmail.com dave.goerlich@the-refinery.io manuel.schonlaub@prodigygame.com]
  s.homepage    = 'https://github.com/the-refinery/sparkpost_rails'
  s.summary     = 'SparkPost for Rails'
  s.description = 'Delivery Method for Rails ActionMailer to send emails using the SparkPost API'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.7.0'

  s.files = Dir['{lib}/**/*'] + %w[LICENSE README.md]

  %w[actionmailer railties].each do |rails_gem|
    s.add_dependency rails_gem, '> 6.1.0', '< 8.0.0'
  end

  s.add_development_dependency 'appraisal', '~> 2.5.0'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '>= 3.4.0'
  s.add_development_dependency 'rubocop', '~> 1.55'
  s.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  s.add_development_dependency 'rubocop-rspec', '~> 2.0.0'
  s.add_development_dependency 'webmock', '>= 1.24.2'
  s.metadata['rubygems_mfa_required'] = 'true'
end
