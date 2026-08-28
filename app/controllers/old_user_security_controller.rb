class UserSecurityController < EmailAuthController 
  skip_before_action :authorize_user!

  def send_code
    email = params[:email]

    if User.where.not(id: Current.user.id).exists?(email: email)
      flash.now[:alert] = "That email is already in use."
      render :new, status: :unprocessable_entity and return
    end

    generate_and_send_otp(email)
    redirect_to security_verify_code_path
  end

  def verify
    @email = session[:email]
    redirect_to security_path if @email.blank?
  end

  def create
    otp_secret = session[:otp_secret]
    email = session[:email]

    if otp_secret.blank? || email.blank?
      redirect_to security_path and return
    end

    unless verify_otp_code(otp_secret, params[:otp_code])
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
    set_session_cookie(new_session)
    Current.session = new_session

    redirect_to user_todos_path(Current.user), notice: "OTP enabled. You can now sign in from any device."
  end

end
