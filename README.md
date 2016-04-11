[![Gem Version](https://badge.fury.io/rb/sparkpost_rails.svg)](https://badge.fury.io/rb/sparkpost_rails)
[![Build Status](https://travis-ci.org/the-refinery/sparkpost_rails.svg?branch=master)](https://travis-ci.org/the-refinery/sparkpost_rails)

SparkPost Rails
===============

This gem provides seamless integration of SparkPost with ActionMailer. It provides a delivery_method based upon the SparkPost API, and
makes getting setup and sending email via SparkPost in a Rails app pretty painless.

Getting Started
---------------

Add the gem to your Gemfile

```
gem 'sparkpost_rails'
```

Then run the bundle command to install it.

By default, the gem will look for your SparkPost API key in your environment, with the key 'SPARKPOST_API_KEY'.  You can override this 
setting by identifying a different key in the initializer (`config/initializers/sparkpost_rails.rb`):

```
SparkPostRails.configure do |c|
  c.api_key = 'YOUR API KEY'
end
```

In each environment configuration file from which you want to send emails via Sparkpost, (i.e. `config/environments/production.rb`) add

```
config.action_mailer.delivery_method = :sparkpost
```

Additional Configuration
------------------------
You can establish values for a number of SparkPost settings in the initializer.  These values will be used for every message sent 
from your application.  You can override these settings on individual messages.

```
SparkPostRails.configure do |c|
  c.sandbox = true
  c.track_opens = true
  c.track_clicks = true
  c.return_path = 'BOUNCE-EMAIL@YOUR-DOMAIN.COM'
  c.campaign_id = 'YOUR-CAMPAIGN'
  c.transactional = true
  c.ip_pool = "MY-POOL"
end
```

The default values for these optional configuration settings are:

```
sandbox = false
track_opens = false
track_clicks = false
return_path = nil
campaign_id = nil
transactional = false
ip_pool = nil
```

Usage
-----
When calling the deliver! method on the mail object returned from your mailer, SparkPostRails provides the response data directly back
from SparkPost as a hash.

```
result = MyMailer.welcome_message(user).deliver!
```

Example:

```
{"total_rejected_recipients"=>0, "total_accepted_recipients"=>1, "id"=>"00000000000000"}
```

If the SparkPost API reponds with an error condition, SparkPostRails will raise a SparkPostRails::DeliveryException, which will include all the message
data returned by the API.

SparkPostRails will support multiple recipients, multilple CC, multiple BCC, ReplyTo address, file attachments, inline images, multi-part (HTML and plaintext) messages - 
all utilizing the standard ActionMailer methodologies.


SparkPost Specific Features
---------------------------

### Configuration Settings
You can specifiy values for any or all of the configuration settings listed above on an individual message.  Simply add a hash of these values
to the mail message in a field named "sparkpost_data":

```
data = { track_opens: true,
         track_clicks: false,
         campaign_id: "My Campaign",
         transactional: true,
         ip_pool = "SPECIAL_POOL",
         subaccount_api_key = "SUBACCOUNT_API_KEY"
       }

mail(to: to_email, subject: "Test", body: "test", sparkpost_data: data)
```

Additionally, return_path can be overriden on a specific email by setting that field on the mail message itself:

```
mail(to: to_email, subject: "Test", body: "test", return_path: "bounces@example.com")
```

### Transmission Specific Settings

For an individual transmisison you can specifiy that SparkPost should ignore customer supression rules - if your SparkPost account allows for this 
feature.  Simply include the flag in the "sparkpost_data" field on the message:

```
data = { skip_suppression: true }

mail(to: to_email, subject: "Test", body: "test", sparkpost_data: data)
```

To schedule the generation of messages for a future date and time, specify a start time in the date parameter of the mail. Date must be in the future and less than 1 year from today. If date is in the past or too far in the future, no date will be passed, and no delivery schedule will be set.

```
start_time = DateTime.now + 4.hours 

mail(to: to_email, subject: "Test", body: "test", date: start_time)
```

You can set a description for a transmission via the "sparkpost_data" as well.  The maximum length of the decription is 1024 characters - values
longer than the maxium will be truncated.

```
data = { description: "My Important Message" }

mail(to: to_email, subject: "Test", body: "test", sparkpost_data: data)
```

### Recipient Lists
SparkPostRails supports using SparkPost stored recipient lists.  Simply add the list_id to the sparkpost_data hash on the mail message:

```
data = { list_id: "MY-LIST"}

mail(subject: "Test", body: "test", sparkpost_data: data)
```

**NOTE**: If you supply a recipient list id, all To:, CC:, and BCC: data specified on the mail message will be ignored.  The SparkPost API does
not support utilizing both a recipient list and inline recipients.


### Substitution Data
You can leverage SparkPost's substitution engine through the gem as well.  To supply substitution data, simply add your hash of substitution data
to your sparkpost_data hash, with the key :substitution_data.

```
sub_data = {first_name: "Sam",
            last_name: "Test}

data = { substitution_data: sub_data }

mail(to: to_email, subject: "Test", body: "test", sparkpost_data: data)
```

### Using SparkPost Templates
If you would rather leverage SparkPost's powerful templates rather than building ActionMailer views, SparkPostRails can support that as well.  Simply
add your template id to the sparkpost_data hash:

```
data = { template_id: "MY-TEMPLATE" }

mail(to: to_email, sparkpost_data: data)
```

**NOTE**: All inline-content that may exist in your mail message will be ignored, as the SparkPost API does not accept that data when a template id is 
supplied.  This includes Subject, From, ReplyTo, Attachments, and Inline Images.


Update Note!
============

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
