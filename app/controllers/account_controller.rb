class AccountController < EmailAuthController
  before_action :require_guest

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

  def create
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

    redirect_to user_todos_path(Current.user), notice: "Email added — you can now sign in from any device."
  end

  private

  def require_guest
    redirect_to root_path unless Current.user && !Current.user.otp_user?
  end
end
