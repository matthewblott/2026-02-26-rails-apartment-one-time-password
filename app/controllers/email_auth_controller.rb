class EmailAuthController < ApplicationController
  private

  def deliver_otp(email, otp_code)
    UserMailer.with(email: email, otp_code: otp_code).send_otp.deliver_now
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
