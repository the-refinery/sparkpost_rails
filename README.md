# Sparkpost Rails

In `Gemfile` add

```
gem 'sparkpost_rails', :github => 'kevinkimball/sparkpost_rails'
```

In `config/initializers/sparkpost_rails.rb` add

```
SparkpostRails.configure do |c|
  c.api_key = 'YOUR API KEY'
  c.track_opens = true
  c.track_clicks = true
  c.return_path = 'example-bounce@example.com'
  c.campaign_id = 'christmas-campaign'
end
```

In `config/environments/production.rb` add

```
config.action_mailer.delivery_method = :sparkpost
```
