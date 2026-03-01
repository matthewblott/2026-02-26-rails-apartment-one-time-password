class RegistrationsController < EmailAuthController 
  skip_before_action :authenticate_user!
  skip_before_action :authorize_user!

  def send_code
    email = params[:email]

    if User.exists?(email: email)
      flash.now[:alert] = "An account with that email already exists."
      render :new, status: :unprocessable_entity and return
    end

    generate_and_send_otp(email)
    redirect_to registration_verify_code_path
  end

  def verify
    @email = session[:email]
    redirect_to registration_path if @email.blank?
  end

  def create
    otp_secret = session[:otp_secret]
    email = session[:email]

    if otp_secret.blank? || email.blank?
      redirect_to registration_path and return
    end

    unless verify_otp_code(otp_secret, params[:otp_code])
      flash.now[:alert] = "Invalid or expired code."
      @email = email
      render :verify, status: :unprocessable_entity and return
    end

    user = User.create!(
      email: email,
      otp_secret: otp_secret,
      otp_enabled: true
    )

    session.delete(:otp_secret)
    session.delete(:email)

    new_session = user.sessions.create!
    set_session_cookie(new_session)
    Current.session = new_session
    Current.user = user

    redirect_to user_todos_path(user), notice: "Account created. You can now sign in from any device."
  end
end
