class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user! #, only: [ :home, :about ]
  skip_before_action :authorize_user!

  def info
    user = Current.user
    if user.nil?
      return
    end
    redirect_to user_home_path(user.id)
  end

end
