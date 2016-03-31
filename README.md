[![Build Status](https://travis-ci.org/the-refinery/sparkpost_rails.svg?branch=master)](https://travis-ci.org/the-refinery/sparkpost_rails)

# SparkPost Rails

In `Gemfile` add

```
gem 'sparkpost_rails', :github => 'the-refinery/sparkpost_rails'
```

By default, the gem will look for your SparkPost API key in your environment, with the key
'SPARKPOST_API_KEY'.  You can override this setting by identifying a different key in the initializer 
(`config/initializers/sparkpost_rails.rb`):

```
SparkPostRails.configure do |c|
  c.api_key = 'YOUR API KEY'
end
```

Additionally, the following configuration options are available to be set in your initializer 
( `config/initializers/sparkpost_rails.rb`):

```
SparkPostRails.configure do |c|
  c.track_opens = true
  c.track_clicks = true
  c.return_path = 'BOUNCE-EMAIL@YOUR-DOMAIN.COM'
  c.campaign_id = 'YOUR-CAMPAIGN'
end
```

The default values for these optional configuration settings are:

```
track_opens = false
track_clicks = false
return_path = nil
campaign_id = nil
```

In `config/environments/production.rb` add

```
config.action_mailer.delivery_method = :sparkpost
```

The deliver! method returns the response data from the SparkPost API call as a hash:

```
response = UserMailer.welcome_email(user).deliver_now!
```

Example:

```
{"total_rejected_recipients"=>0, "total_accepted_recipients"=>1, "id"=>"00000000000000"}
```

# Update Note!

If you have been using Version 0.0.5 or earlier of this gem, when you upgrade, you'll need to 
change your initalizer as follows:

```
SparkpostRails.configure do |c|
```

becomes: 

```
SparkPostRails.configure do |c|
```

We have changed the module name to align with the official SparkPost gem's naming convention.
