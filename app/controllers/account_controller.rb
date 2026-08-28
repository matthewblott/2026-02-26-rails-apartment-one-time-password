class AccountController < EmailAuthController

  def index
  end

  def send_code
    email = params[:email].to_s.strip.downcase

    # if User.exists?(email: email)
    if User.where(otp_enabled: true).exists?(email: email)
      flash.now[:alert] = "An account with that email already exists."
      render :new, status: :unprocessable_entity and return
    end

    generate_and_send_otp(email)
    redirect_to user_account_verify_code_path
  end

  def verify
    @email = session[:email]
    redirect_to session_path if @email.blank?
  end

  def create
    otp_secret = session[:otp_secret]
    email = session[:email]

    unless verify_otp_code(otp_secret, params[:otp_code])
      flash.now[:alert] = "Invalid or expired code."
      @email = email
      render :verify, status: :unprocessable_entity and return
    end

    Current.user.update!(email: email, otp_secret: otp_secret, otp_enabled: true)

    session.delete(:otp_secret)
    session.delete(:email)

    new_session = Current.user.sessions.create!
    set_session_cookie(new_session)
    Current.session = new_session
    # Current.user = user

    redirect_to user_todos_path(Current.user), notice: "Account created. You can now sign in from any device."

  end

end
