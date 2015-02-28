Gem::Specification.new do |s|
  s.name        = 'sparkpost_rails'
  s.version     = '0.0.1'
  s.date        = '2015-02-28'
  s.summary     = "Sparkpost for Rails"
  s.description = "Delivery Method for sending emails via Sparkpost REST API in Rails"
  s.authors     = ["Kevin Kimball"]
  s.email       = 'kwkimball@gmail.com'
  s.files       = [
                    "lib/sparkpost_rails.rb",
                    "lib/sparkpost_rails/delivery_method.rb",
                    "lib/sparkpost_rails/railtie.rb"
                  ]
  s.homepage    = 'https://github.com/kevinkimball/sparkpost-rails'
  s.license     = 'MIT'
end
