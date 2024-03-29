require 'rails_helper'

RSpec.describe 'routes', type: :routing do
  it {
    expect(get('/users/password/edit?reset_password_token=blah'))
        .to route_to ({
                controller: 'devise/passwords',
                action: 'edit',
                reset_password_token: 'blah'
        })
  }
  it { expect(get('/change_password')).to route_to('users#change_password')}
  it { expect(get('/subscriptions/1/edit')).not_to route_to('subscriptions#edit') }
  it { expect(delete('/subscriptions/1')).not_to route_to('subscriptions#destroy') }
end