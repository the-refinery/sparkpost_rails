# Rails Compatibility Matrix

This document outlines the compatibility of SparkPost Rails gem with different Rails versions.

## Supported Rails Versions

| Rails Version | Status | Tested | Notes |
|---------------|--------|--------|-------|
| Rails 4.0+    | ✅ Supported | ✅ | Full compatibility |
| Rails 5.0+    | ✅ Supported | ✅ | Full compatibility |
| Rails 6.0+    | ✅ Supported | ✅ | Full compatibility |
| Rails 7.0+    | ✅ Supported | ✅ | Full compatibility |
| Rails 7.1+    | ✅ Supported | ✅ | Full compatibility |

## Key Changes for Rails 7.x Compatibility

### Version 1.6.0
- Updated dependency constraints to support Rails 4.0 through 7.x
- Improved mail method handling in `data_options.rb` for better Rails 7.x compatibility
- Updated gemspec to allow Rails 7.x versions
- All existing functionality remains backward compatible

### Technical Details

The gem uses the following Rails components:
- `ActionMailer::Base` - For mailer functionality
- `ActionMailer::DeliveryMethod` - For custom delivery method
- `Rails::Railtie` - For Rails integration
- `ActiveSupport.on_load` - For proper initialization timing

All of these components are stable across Rails 4.0 through 7.x, ensuring compatibility.

## Testing

The gem includes a comprehensive test suite that runs against Rails 7.1.5.2 and passes all 116 tests.

To test with different Rails versions:

```bash
# Test with Rails 7.x
bundle exec rspec

# Test with specific Rails version (modify Gemfile)
gem "rails", "~> 7.0.0"
bundle update
bundle exec rspec
```

## Migration Notes

No migration is required when upgrading from Rails 6.x to Rails 7.x. The gem will work seamlessly with existing code.

## Known Issues

None currently identified. The gem has been thoroughly tested with Rails 7.x and all functionality works as expected.
