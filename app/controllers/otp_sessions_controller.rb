class OtpSessionsController < OtpBaseController
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

    generate_and_send_otp(email)
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
      set_session_cookie(new_session)
      redirect_to user_todos_path(user)
    else
      flash.now[:alert] = "Invalid or expired code."
      @email = email
      render :verify, status: :unprocessable_entity
    end
  end

end
