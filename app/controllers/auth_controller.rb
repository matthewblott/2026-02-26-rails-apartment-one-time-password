class AuthController < EmailAuthController
  skip_before_action :authenticate_user!
  before_action :redirect_if_authenticated

  def new
  end

  def send_code
    email = params[:email].to_s.strip.downcase

    if email.blank?
      flash.now[:alert] = "Please enter an email address."
      render :new, status: :unprocessable_entity and return
    end

    existing_user = User.find_by(email: email)
    otp_secret = existing_user&.otp_secret || User.generate_otp_secret

    session[:email] = email
    session[:otp_secret] = otp_secret

    deliver_otp(email, User.otp_for_secret(otp_secret).now)

    redirect_to auth_verify_code_path
  end

  def verify
    @email = session[:email]
    redirect_to sign_in_path if @email.blank?
  end

  def create
    email = session[:email]
    otp_secret = session[:otp_secret]

    if email.blank? || otp_secret.blank?
      redirect_to sign_in_path and return
    end

    unless User.otp_for_secret(otp_secret).verify(params[:otp_code], drift_behind: 30)
      flash.now[:alert] = "Invalid or expired code."
      @email = email
      render :verify, status: :unprocessable_entity and return
    end

    user = User.find_by(email: email)
    is_new_user = user.nil?
    user ||= User.create!(email: email, otp_secret: otp_secret, otp_enabled: true)

    session.delete(:otp_secret)
    session.delete(:email)

    new_session = user.sessions.create!
    set_session_cookie(new_session)
    Current.session = new_session
    Current.user = user

    notice = is_new_user ? "Account created. You can now sign in from any device." : nil
    redirect_to user_todos_path(user), notice: notice
  end

  def redirect_if_authenticated
    redirect_to user_todos_path(Current.user) if Current.user
  end
end
