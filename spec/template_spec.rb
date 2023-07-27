# frozen_string_literal: true

require 'spec_helper'

describe SparkPostRails::DeliveryMethod do
  before do
    @delivery_method = SparkPostRails::DeliveryMethod.new
  end

  context 'Templates' do
    it 'accepts the template id to use' do
      test_email = Mailer.test_email sparkpost_data: { template_id: 'test_template' }

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content][:template_id]).to eq('test_template')
    end

    it 'does not include inline content elements' do
      test_email = Mailer.test_email sparkpost_data: { template_id: 'test_template' }

      @delivery_method.deliver!(test_email)

      expect(@delivery_method.data[:content].key?(:from)).to eq(false)
      expect(@delivery_method.data[:content].key?(:reply_to)).to eq(false)

      expect(@delivery_method.data[:content].key?(:subject)).to eq(false)

      expect(@delivery_method.data[:content].key?(:html)).to eq(false)
      expect(@delivery_method.data[:content].key?(:text)).to eq(false)
      expect(@delivery_method.data[:content].key?(:attachments)).to eq(false)
      expect(@delivery_method.data[:content].key?(:inline_images)).to eq(false)
    end
  end
end
