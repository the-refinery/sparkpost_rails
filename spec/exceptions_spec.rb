# frozen_string_literal: true

require 'spec_helper'

describe SparkPostRails::DeliveryException do
  subject { SparkPostRails::DeliveryException.new(error) }

  describe 'string' do
    let(:error) { 'Some delivery error' }

    it 'preserves original message' do
      raise subject
    rescue SparkPostRails::DeliveryException => e
      expect(error).to eq(e.message)
    end
  end

  describe 'array with error details' do
    let(:error) do
      [{ 'message' => 'Message generation rejected', 'description' => 'recipient address suppressed due to customer policy',
         'code' => '1902' }]
    end

    it 'assigns message' do
      expect(subject.service_message).to eq('Message generation rejected')
    end

    it 'assigns description' do
      expect(subject.service_description).to eq('recipient address suppressed due to customer policy')
    end

    it 'assigns code' do
      expect(subject.service_code).to eq('1902')
    end

    it 'preserves original message' do
      raise subject
    rescue SparkPostRails::DeliveryException => e
      expect(error.to_s).to eq(e.message)
    end
  end

  describe 'array with partial details' do
    let(:error) { [{ 'message' => 'end of world' }] }

    it 'assigns message' do
      expect(subject.service_message).to eq('end of world')
    end

    it 'assigns description' do
      expect(subject.service_description).to be nil
    end

    it 'assigns code' do
      expect(subject.service_code).to be nil
    end

    it 'preserves original message' do
      raise subject
    rescue SparkPostRails::DeliveryException => e
      expect(error.to_s).to eq(e.message)
    end
  end
end
