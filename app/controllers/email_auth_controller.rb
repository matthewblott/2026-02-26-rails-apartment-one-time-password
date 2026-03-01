class EmailAuthController < ApplicationController
  private

  def generate_and_send_otp(email)
    otp_secret = ROTP::Base32.random_base32
    otp_code = ROTP::TOTP.new(otp_secret, issuer: "MyApp").now

    session[:otp_secret] = otp_secret
    session[:email] = email

    UserMailer.with(email:, otp_code:).send_otp.deliver_now

    otp_secret
  end

  def send_otp(user)
    otp_code = user.otp.now
    session[:email] = user.email
    UserMailer.with(email: user.email, otp_code:).send_otp.deliver_now
  end

  def verify_otp_code(otp_secret, code)
    ROTP::TOTP.new(otp_secret, issuer: "MyApp").verify(code, drift_behind: 30)
  end

  def set_session_cookie(new_session)
    cookies.signed.permanent[:session_token] = {
      value: new_session.id,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }
  end

end
