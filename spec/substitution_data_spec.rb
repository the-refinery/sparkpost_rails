# frozen_string_literal: true

require 'spec_helper'

describe SparkPostRails::DeliveryMethod do
  before do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context 'Substitution Data' do
    it 'accepts substitution data with template-based message' do
      sub_data = { item1: 'test data 1', item2: 'test data 2' }

      test_email = Mailer.test_email sparkpost_data: { template_id: 'test_template', substitution_data: sub_data }

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:substitution_data]).to eq(sub_data)
    end

    it 'accepts substitution data with inline-content message' do
      sub_data = { item1: 'test data 1', item2: 'test data 2' }

      test_email = Mailer.test_email sparkpost_data: { substitution_data: sub_data }

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:substitution_data]).to eq(sub_data)
    end

    it 'does not include substitution data element if none is passed' do
      test_email = Mailer.test_email sparkpost_data: { template_id: 'test_template' }
      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data.key?(:substitution_data)).to eq(false)
    end
  end
end
