class DashboardController < ApplicationController
  def show
    # TODO: Cache and AJAX
    @media = JSON.parse(Net::HTTP.get(URI('https://cdn.jwplayer.com/v2/playlists/lnBWhBPe')))['playlist'];
  end
end
