class OtpEnrolmentsController < ApplicationController
  skip_before_action :authorize_user!

  def send_code
    email = params[:email]

    if User.where.not(id: Current.user.id).exists?(email: email)
      flash.now[:alert] = "That email is already in use."
      render :new, status: :unprocessable_entity and return
    end

    otp_secret = ROTP::Base32.random_base32
    otp = ROTP::TOTP.new(otp_secret, issuer: "MyApp")
    otp_code = otp.now

    session[:otp_secret] = otp_secret
    session[:email] = email

    UserMailer.with(email:, otp_code:).send_otp.deliver_now

    redirect_to otp_enrolment_verify_path
  end

  def verify
    @email = session[:email]
    redirect_to otp_enrolment_path if @email.blank?
  end

  def create
    otp_secret = session[:otp_secret]
    email = session[:email]

    if otp_secret.blank? || email.blank?
      redirect_to otp_enrolment_path and return
    end

    otp = ROTP::TOTP.new(otp_secret, issuer: "MyApp")

    unless otp.verify(params[:otp_code], drift_behind: 30)
      flash.now[:alert] = "Invalid or expired code."
      @email = email
      render :verify, status: :unprocessable_entity and return
    end

    Current.user.update!(
      email: email,
      otp_secret: otp_secret,
      otp_enabled: true,
      device_token: nil
    )

    session.delete(:otp_secret)
    session.delete(:email)

    new_session = Current.user.sessions.create!

    cookies.delete(:device_token)

    cookies.signed.permanent[:session_token] = {
      value: new_session.id,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }

    Current.session = new_session

    redirect_to user_todos_path(Current.user), notice: "OTP enabled. You can now sign in from any device."
  end
end
