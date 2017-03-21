class DashboardController < ApplicationController
  def show
    @media = JSON.parse(Net::HTTP.get(URI('https://cdn.jwplayer.com/v2/playlists/lnBWhBPe')))['playlist']; # TODO: Cache and AJAX
  end
end
