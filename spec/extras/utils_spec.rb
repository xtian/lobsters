# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Utils do
  describe '.silence_streams' do
    it 'is defined' do
      expect(described_class.methods).to include(:silence_stream)
    end
  end
end
