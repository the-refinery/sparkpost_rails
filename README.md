[![Gem Version](https://badge.fury.io/rb/sparkpost_rails.svg)](https://badge.fury.io/rb/sparkpost_rails)
[![Build Status](https://travis-ci.org/the-refinery/sparkpost_rails.svg?branch=master)](https://travis-ci.org/the-refinery/sparkpost_rails)

SparkPost Rails
===============

This gem provides seamless integration of SparkPost with ActionMailer. It provides a `delivery_method` based upon the SparkPost API, and makes getting setup and sending email via SparkPost in a Rails app pretty painless.

Getting Started
---------------

Add the gem to your Gemfile

```ruby
gem 'sparkpost_rails'
```

Then run the bundle command to install it.

By default, the gem will look for your SparkPost API key in your environment, with the key `SPARKPOST_API_KEY`.  You can override this setting by identifying a different key in the initializer (`config/initializers/sparkpost_rails.rb`):

```ruby
SparkPostRails.configure do |c|
  c.api_key = 'YOUR API KEY'
end
```
Note that an initializer file is not required to use this gem. If an initializer is not provided, default values will be used. See ["Additional Configuration"](#additional-configuration) below for a list of all the default settings.

In each environment configuration file from which you want to send emails via Sparkpost, (i.e. `config/environments/production.rb`) add

```ruby
config.action_mailer.delivery_method = :sparkpost
```

Additional Configuration
------------------------
You can establish values for a number of SparkPost settings in the initializer. These values will be used for every message sent from your application. You can override these settings on individual messages.

```ruby
SparkPostRails.configure do |c|
  c.sandbox = true                                # default: false
  c.track_opens = true                            # default: false
  c.track_clicks = true                           # default: false
  c.return_path = 'BOUNCE-EMAIL@YOUR-DOMAIN.COM'  # default: nil
  c.campaign_id = 'YOUR-CAMPAIGN'                 # default: nil
  c.transactional = true                          # default: false
  c.ip_pool = "MY-POOL"                           # default: nil
  c.inline_css = true                             # default: false
  c.html_content_only = true                      # default: false
  c.subaccount = "123"                            # default: nil
end
```

Usage
-----
When calling the `deliver!` method on the mail object returned from your mailer, `SparkPostRails` provides the response data directly back from SparkPost as a hash.

```ruby
result = MyMailer.welcome_message(user).deliver!
```

Example:

```ruby
{
  "total_rejected_recipients" => 0, 
  "total_accepted_recipients" => 1, 
  "id" => "00000000000000"
}
```

If the SparkPost API reponds with an error condition, SparkPostRails will raise a `SparkPostRails::DeliveryException`, which will include all the message data returned by the API.

SparkPostRails will support multiple recipients, multilple CC, multiple BCC, ReplyTo address, file attachments, inline images, multi-part (HTML and plaintext) messages - all utilizing the standard `ActionMailer` methodologies.

Handling Errors
---------------
If you are using `ActiveJob` and wish to do something special when the SparkPost API responds with an error condition you can do so by rescuing these exceptions via `ActionMailer::DeliveryJob`. Simply add an initializer:

`config/initializers/action_mailer.rb`

```ruby
ActionMailer::DeliveryJob.rescue_from(SparkPostRails::DeliveryException) do |exception|
  # do something special with the error
end
```

SparkPost-Specific Features
---------------------------

### Configuration Settings
You can specifiy values for any or all of the configuration settings listed above on an individual message. Simply add a hash of these values to the mail message in a field named `sparkpost_data`:

```ruby
data = { 
  track_opens: true,
  track_clicks: false,
  campaign_id: "My Campaign",
  transactional: true,
  ip_pool = "SPECIAL_POOL",
  api_key = "MESSAGE_SPECIFIC_API_KEY"
  subaccount = "123"
}

mail(to: to_email, subject: "Test", body: "test", sparkpost_data: data)
```

Additionally, `return_path` can be overriden on a specific email by setting that field on the mail message itself:

```ruby
mail(to: to_email, subject: "Test", body: "test", return_path: "bounces@example.com")
```

### Transmission Specific Settings

For an individual transmisison you can specifiy that SparkPost should ignore customer supression rules - if your SparkPost account allows for this feature. Simply include the flag in the `sparkpost_data` field on the message:

```ruby
data = { skip_suppression: true }

mail(to: to_email, subject: "Test", body: "test", sparkpost_data: data)
```

To schedule the generation of messages for a future date and time, specify a start time in the `date` parameter of the mail. The `date` must be in the future and less than 1 year from today. If `date` is in the past or too far in the future, no date will be passed, and no delivery schedule will be set.

```ruby
start_time = DateTime.now + 4.hours 

mail(to: to_email, subject: "Test", body: "test", date: start_time)
```

You can set a `description` for a transmission via the `sparkpost_data` as well. The maximum length of the `decription` is 1024 characters - values longer than the maxium will be truncated.

```ruby
data = { description: "My Important Message" }

mail(to: to_email, subject: "Test", body: "test", sparkpost_data: data)
```

By default, content from single-part messages is sent at plain-text. If you are only intending to send HTML email, with no plain-text part, you can specify this as shown below. You can also set this in the configuration to ensure that all single-part emails are sent as HTML.

```ruby
data = { html_content_only: true }

mail(to: to_email, subject: "Test", body: "<h1>test</h1>", sparkpost_data: data)
```

### Subaccounts

SparkPostRails supports sending messages via subaccounts in two ways. The default API key set in the configuration can be overriden on a message-by-message basis with a subaccount API key.

```ruby
data = { api_key: "SUBACCOUNT_API_KEY" }

mail(subject: "Test", body: "test", sparkpost_data: data)
```

Subaccounts can also be leveraged using the subaccount ID with the master API key.

```ruby
data = { subaccount: "123" }

mail(subject: "Test", body: "test", sparkpost_data: data)
```

### Recipient Lists
SparkPostRails supports using SparkPost stored recipient lists. Simply add the `list_id` to the `sparkpost_data` hash on the mail message:

```ruby
data = { list_id: "MY-LIST"}

mail(subject: "Test", body: "test", sparkpost_data: data)
```

**NOTE**: If you supply a recipient `list_id`, all `To:`, `CC:`, and `BCC:` data specified on the mail message will be ignored. The SparkPost API does not support utilizing both a recipient list and inline recipients.


### Substitution Data
You can leverage SparkPost's substitution engine through the gem as well. To supply substitution data, simply add your hash of substitution data to your `sparkpost_data` hash, with the key `substitution_data`.

```ruby
sub_data = {
  first_name: "Sam",
  last_name: "Test
}

data = { substitution_data: sub_data }

mail(to: to_email, subject: "Test", body: "test", sparkpost_data: data)
```

### Recipient-Specific Data
When sending to multiple recipients, you can pass an array of data to complement each recipient. Simply pass an array called `recipients` containing an array of the additional data (e.g. `substitution_data`).

```ruby
recipients = ['recipient1@email.com', 'recipient2@email.com']
sparkpost_data = {
  recipients: [
    { substitution_data: { name: 'Recipient1' } },
    { substitution_data: { name: 'Recipient2' } }
  ]
}
mail(to: recipients, sparkpost_data: sparkpost_data)
```


### Using SparkPost Templates
You can leverage SparkPost's powerful templates rather than building ActionMailer views using SparkPostRails. Add your `template_id` to the `sparkpost_data` hash. By default, `ActionMailer` finds a template to use within views. A workaround to prevent this default action is to explicitly pass a block with an empty `text` part:

```ruby
data = { template_id: "MY-TEMPLATE" }

mail(to: to_email, sparkpost_data: data) do |format|
  format.text { render text: "" }
end
```

**NOTE**: All inline-content that may exist in your mail message will be ignored, as the SparkPost API does not accept that data when a template id is supplied. This includes `Subject`, `From`, `ReplyTo`, Attachments, and Inline Images.

###Other Mail Headers
If you need to identify custom mail headers for your messages, use the `ActionMailer` `header[]` method. The gem will pass all approprite headers through to the API. Note, per the SparkPost API documentation

> Headers such as 'Content-Type' and 'Content-Transfer-Encoding' are not allowed here as they are auto-generated upon construction of the email.

```ruby
headers["Priority"] = "urgent"
headers["Sensitivity"] = "private"

mail(to: to_email, subject: "Test", body: "test")
```
