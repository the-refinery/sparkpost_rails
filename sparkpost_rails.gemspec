Gem::Specification.new do |s|
  s.name        = 'sparkpost_rails'
  s.version     = '0.0.5'
  s.date        = '2016-03-25'
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
end
