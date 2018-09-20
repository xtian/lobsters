# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Reading Homepage' do
  let!(:story) { create(:story) }

  context 'when logged out' do
    scenario 'reading a story' do
      visit '/'
      expect(page).to have_content(story.title)
    end
  end

  context 'when logged in' do
    let(:user) { create(:user) }
    before(:each) { stub_login_as user }

    scenario 'reading a story' do
      visit '/'
      expect(page).to have_content(story.title)
    end
  end
end
