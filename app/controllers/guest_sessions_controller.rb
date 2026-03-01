class GuestSessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create

  def create
    return redirect_to user_todos_path(Current.user) if Current.user

    user = User.create!

    cookies.permanent.encrypted[:device_token] = {
      value: user.device_token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }

    Current.user = user

    redirect_to user_todos_path(Current.user)
  end

end
