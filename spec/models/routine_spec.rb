require 'rails_helper'

RSpec.describe Routine, type: :model do
  describe 'validations' do
    context 'title' do
      it 'is required' do
        expect(build(:routine, title: nil)).not_to be_valid
      end
    end

    context 'source' do
      it 'is required' do
        expect(build(:routine, source: nil)).not_to be_valid
      end
    end
  end
end
