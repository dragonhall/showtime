class TvController < ApplicationController
  layout 'tv'

  skip_before_action :authenticate_admin!


  def index

  end
end

