class UserMailer < ApplicationMailer
  def send_otp
    @email = params[:email]
    @otp_code = params[:otp_code]
    mail(
      to: @email,
      subject: "#{@otp_code} - Your one-time code"
    )
  end

end
