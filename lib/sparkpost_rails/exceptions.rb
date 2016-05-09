module SparkPostRails
  class DeliveryException < StandardError
    attr_reader :service_message, :service_description, :service_code

    def initialize(message)
      errors = [*message].first

      if errors.is_a?(Hash)
        @service_message     = errors['message']
        @service_description = errors['description']
        @service_code        = errors['code']
      end

      super(message)
    end
  end
end
