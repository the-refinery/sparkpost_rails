# frozen_string_literal: true

module SparkPostRails
  module DataOptions
    def self.included(base)
      base.class_eval do
        prepend InstanceMethods
      end
    end

    module InstanceMethods
      def mail(headers = {}, &)
        headers = headers.clone
        sparkpost_data = headers.delete(:sparkpost_data)
        sparkpost_data ||= {}
        super(headers, &).tap do |message|
          message.singleton_class.class_eval { attr_accessor 'sparkpost_data' }
          message.sparkpost_data = sparkpost_data
        end
      end
    end
  end
end
