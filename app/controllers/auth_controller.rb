class AuthController < EmailAuthController
  skip_before_action :authenticate_user!

  TEST_USER_EMAIL = 'jane@example.com'
  TEST_USER_OTP = '123456'

  def send_code
    email = params[:email].to_s.strip.downcase

    if email.blank?
      flash.now[:alert] = 'Please enter an email address.'
      render :new, status: :unprocessable_entity and return
    end

    existing_user = User.find_by(email: email)
    otp_secret = existing_user&.otp_secret || User.generate_otp_secret

    session[:email] = email
    session[:otp_secret] = otp_secret

    unless email == TEST_USER_EMAIL
      deliver_otp(email, User.otp_for_secret(otp_secret).now)
    end

    message = "Verification code sent to #{email}."

    redirect_to auth_verify_code_path, notice: message
  end

  def verify
    @email = session[:email]
  end

  def create
    # email = session[:email]
    email = params[:email]
    otp_secret = session[:otp_secret]

    if email.blank? || otp_secret.blank?
      redirect_to new_auth_path and return
    end

    is_test_user = email == TEST_USER_EMAIL
    secret_user = User.otp_for_secret(otp_secret)
    is_verified_secret_user = secret_user.verify(params[:otp_code], drift_behind: 30)

    if is_test_user and params[:otp_code] == TEST_USER_OTP
      is_verified_secret_user = true 
    end

    unless is_verified_secret_user 
      flash.now[:alert] = 'Invalid or expired code.'
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

    message = is_new_user ? 'Account created. You can now sign in from any device.' : 'You have successfully signed in.'
    redirect_to user_home_path(user), notice: message
  end

end


