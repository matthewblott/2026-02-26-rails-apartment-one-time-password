class SessionsController < ApplicationController
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

  def destroy
    if Current.user.otp_user?
      session_id = cookies.signed[:session_token]
      Session.find_by(id: session_id)&.destroy
      cookies.delete(:session_token)
      cookies.delete(:device_token)
    else
      Apartment::Tenant.drop(Current.user.id.to_s)
      Current.user.destroy
      cookies.delete(:device_token)
    end

    redirect_to root_path

  end

  private

  def require_user
    redirect_to root_path unless Current.user
  end

end
