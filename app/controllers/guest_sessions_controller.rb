class GuestSessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create

  def create
    if Current.user
      return redirect_to user_home_path(Current.user)
    end

    user = User.create!

    cookies.permanent.encrypted[:device_token] = {
      value: user.device_token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }

    Current.user = user

    redirect_to user_home_path(Current.user)
  end

end
