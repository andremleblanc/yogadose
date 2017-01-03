require 'rails_helper'

RSpec.feature 'Edit Subscription', type: :feature do
  before do
    Sidekiq::Testing.inline!
  end

  after do
    Sidekiq::Testing.fake!
  end

  pending
end
