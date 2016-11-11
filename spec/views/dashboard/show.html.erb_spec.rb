require 'rails_helper'

RSpec.describe "dashboard/show.html.erb", type: :view do
  it "should be blank" do
    render

    expect(rendered).to match /\n/
  end
end
