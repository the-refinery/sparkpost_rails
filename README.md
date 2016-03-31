# Sparkpost Rails

In `Gemfile` add

```
gem 'sparkpost_rails', :github => 'the-refinery/sparkpost_rails'
```


In `config/initializers/sparkpost_rails.rb` add

```
SparkPostRails.configure do |c|
  c.track_opens = true
  c.track_clicks = true
  c.return_path = 'BOUNCE-EMAIL@YOUR-DOMAIN.COM'
  c.campaign_id = 'YOUR-CAMPAIGN'
end
```

By default, the gem will look for your SparkPost API key in your environment, with the key
'SPARKPOST_API_KEY'.  You can override this setting by identifying a different key in the initializer:

```
SparkPostRails.configure do |c|
  c.api_key = 'YOUR API KEY'
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
