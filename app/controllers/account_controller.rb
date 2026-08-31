class AccountController < EmailAuthController
  def index
  end

  def send_code
    email = params[:email].to_s.strip.downcase

    if email.blank?
      flash.now[:alert] = "Please enter an email address."
      render :new, status: :unprocessable_entity and return
    end

    if User.where.not(id: Current.user.id).exists?(email: email)
      flash.now[:alert] = "An account with that email already exists."
      render :new, status: :unprocessable_entity and return
    end

    otp_secret = User.generate_otp_secret
    session[:email] = email
    session[:otp_secret] = otp_secret

    deliver_otp(email, User.otp_for_secret(otp_secret).now)

    redirect_to user_account_verify_code_path
  end

  def verify_code
    email = session[:email]
    otp_secret = session[:otp_secret]

    if email.blank? || otp_secret.blank?
      redirect_to guest_upgrade_path and return
    end

    unless User.otp_for_secret(otp_secret).verify(params[:otp_code], drift_behind: 30)
      flash.now[:alert] = "Invalid or expired code."
      @email = email
      render :verify, status: :unprocessable_entity and return
    end

    # Re-check uniqueness at the point of write, in case it was taken
    # by someone else between send_code and now.
    if User.where.not(id: Current.user.id).exists?(email: email)
      flash.now[:alert] = "An account with that email already exists."
      @email = email
      render :verify, status: :unprocessable_entity and return
    end

    Current.user.update!(email: email, otp_secret: otp_secret, otp_enabled: true)

    session.delete(:otp_secret)
    session.delete(:email)

    redirect_to user_home_path(Current.user), notice: "Email added — you can now sign in from any device."
  end

  def sign_out 
    session_id = cookies.signed[:session_token]
    Session.find_by(id: session_id)&.destroy
    cookies.delete(:session_token)
    cookies.delete(:device_token)
    redirect_to root_path
  end
  
  def destroy
    Current.user.destroy
    cookies.delete(:device_token)
    redirect_to root_path
  end

end
