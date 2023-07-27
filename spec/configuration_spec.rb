# frozen_string_literal: true

require 'spec_helper'

describe 'SparkPostRails configuration' do
  let(:delivery_method) { SparkPostRails::DeliveryMethod.new }

  describe '#configuration' do
    it 'creates a new configuration + defaults if #configure is never called', skip_configure: true do
      config = SparkPostRails.configuration
      expect(config).not_to be_nil
    end
  end
end
