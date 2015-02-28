Gem::Specification.new do |s|
  s.name        = 'sparkpost_rails'
  s.version     = '0.0.3'
  s.date        = '2015-02-28'
  s.summary     = "Sparkpost for Rails"
  s.description = "Delivery Method for Rails ActionMailer to send emails using the Sparkpost API"
  s.authors     = ["Kevin Kimball"]
  s.email       = 'kwkimball@gmail.com'
  s.homepage    = 'https://github.com/kevinkimball/sparkpost_rails'
  s.license     = 'MIT'
  s.files       = [
                    "lib/sparkpost_rails.rb",
                    "lib/sparkpost_rails/delivery_method.rb",
                    "lib/sparkpost_rails/railtie.rb"
                  ]

  s.add_runtime_dependency 'httparty', ['>= 0.13.3']
end
