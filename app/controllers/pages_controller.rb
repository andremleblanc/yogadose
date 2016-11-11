class PagesController < ApplicationController
  include HighVoltage::StaticPage
  layout 'frontend'
end
