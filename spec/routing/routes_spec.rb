require 'rails_helper'

RSpec.describe 'routes', type: :routing do
  it { expect(get('/account')).to route_to('users#edit') }
  it {
    expect(get('/users/password/edit?reset_password_token=blah'))
        .to route_to ({
                controller: 'devise/passwords',
                action: 'edit',
                reset_password_token: 'blah'
        })
  }
end