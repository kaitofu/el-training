class StaticPagesController < ApplicationController
  skip_before_action :login_required

  def about
  end
end
