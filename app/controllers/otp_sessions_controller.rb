class OtpSessionsController < ApplicationController
  skip_before_action :load_current_user
  skip_before_action :authenticate_user!
  skip_before_action :authorize_user!

  def send_code
    email = params[:email]
    user = User.find_by(email: email, otp_enabled: true)

    if user.blank?
      flash.now[:alert] = "No OTP account found for that email."
      render :new, status: :unprocessable_entity and return
    end

    otp_code = user.otp.now

    UserMailer.with(email:, otp_code:).send_otp.deliver_now

    session[:email] = email
    redirect_to otp_verify_path
  end

  def verify
    @email = session[:email]
    redirect_to otp_sign_in_path if @email.blank?
  end

  def create
    email = session[:email]
    user = User.find_by(email: email, otp_enabled: true)

    if user&.valid_otp?(params[:otp_code])
      new_session = user.sessions.create!
      session.delete(:email)

      cookies.signed.permanent[:session_token] = {
        value: new_session.id,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax
      }

      redirect_to user_todos_path(user)
    else
      flash.now[:alert] = "Invalid or expired code."
      @email = email
      render :verify, status: :unprocessable_entity
    end

  end

end
