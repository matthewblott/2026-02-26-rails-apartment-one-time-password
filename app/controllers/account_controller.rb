class AccountController < EmailAuthController
  # skip_before_action :load_current_user, only: %i[new send_code verify create]
  # skip_before_action :authenticate_user!, only: %i[new send_code verify create]
  # skip_before_action :authorize_user!, only: %i[new send_code verify create]

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
    # email = session[:email]
    # user = User.find_by(email: email, otp_enabled: true)
    #
    # if user&.valid_otp?(params[:otp_code])
    #
    #   new_session = user.sessions.create!
    #
    #   session.delete(:email)
    #   set_session_cookie(new_session)
    #   redirect_to user_todos_path(user)
    # else
    #   flash.now[:alert] = "Invalid or expired code."
    #   @email = email
    #   render :verify, status: :unprocessable_entity
    # end

    otp_secret = session[:otp_secret]
    email = session[:email]

    unless verify_otp_code(otp_secret, params[:otp_code])
      flash.now[:alert] = "Invalid or expired code."
      @email = email
      render :verify, status: :unprocessable_entity and return
    end

    # user = User.create!(
    #   email: email,
    #   otp_secret: otp_secret,
    #   otp_enabled: true
    # )

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
