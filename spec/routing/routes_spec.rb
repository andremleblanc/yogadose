require 'rails_helper'

RSpec.describe 'routes', type: :routing do
  it { expect(get('/account')).to route_to('users#edit') }
end