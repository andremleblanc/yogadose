module Helpers
  def sign_in_inactive_user
    sign_in(user)
    allow(subject).to receive(:current_user).and_return(user)
    expect(user).to receive(:active?).and_return(false)
  end

  def sign_in_active_user
    sign_in(user)
    allow(subject).to receive(:current_user).and_return(user)
    expect(user).to receive(:active?).and_return(true)
  end
end