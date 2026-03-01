class SessionsController < EmailAuthController
  skip_before_action :load_current_user, only: %i[new send_code verify create]
  skip_before_action :authenticate_user!, only: %i[new send_code verify create]
  skip_before_action :authorize_user!, only: %i[new send_code verify create]

  def send_code
    email = params[:email]
    user = User.find_by(email: email, otp_enabled: true)
    
    if user.blank?
      flash.now[:alert] = "No OTP account found for that email."
      render :new, status: :unprocessable_entity and return
    end

    # generate_and_send_otp(email)
    send_otp(user)

    redirect_to session_verify_code_path
  end

  def verify
    @email = session[:email]
    redirect_to session_path if @email.blank?
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

  def destroy
    if Current.user.otp_user?
      session_id = cookies.signed[:session_token]
      Session.find_by(id: session_id)&.destroy
      cookies.delete(:session_token)
      cookies.delete(:device_token)
    else
      Apartment::Tenant.drop(Current.user.id.to_s)
      Current.user.destroy
      cookies.delete(:device_token)
    end

    redirect_to root_path
  end

end
