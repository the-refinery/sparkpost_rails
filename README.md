# Sparkpost Rails

In `Gemfile` add

```
gem 'sparkpost_rails', :github => 'the-refinery/sparkpost_rails'
```

In `config/initializers/sparkpost_rails.rb` add

```
SparkpostRails.configure do |c|
  c.api_key = 'YOUR API KEY'
  c.track_opens = true
  c.track_clicks = true
  c.return_path = 'BOUNCE-EMAIL@YOUR-DOMAIN.COM'
  c.campaign_id = 'YOUR-CAMPAIGN'
end
```

In `config/environments/production.rb` add

```
config.action_mailer.delivery_method = :sparkpost
```

Deliver method returns the Sparkpost response
```
response = UserMailer.welcome_email(user).deliver_now!
```
