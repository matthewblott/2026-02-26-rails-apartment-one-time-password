class User < AuthRecord
  # Don't create the User record until the OTP is verified — for both new and existing users.
  # That means at the "send code" step you need an OTP secret that works whether or not a user exists yet:
  # Existing user →
  #   reuse their stored otp_secret (so the code matches what valid_otp? will check later)
  # New user →
  #   generate a fresh secret, stash it in the session, and only persist it when you create the User on verification

  has_many :sessions, dependent: :destroy
  before_validation :generate_device_token, on: :create
  validates :device_token, presence: false, uniqueness: true, allow_nil: true
  validates :email, presence: false, uniqueness: true, allow_nil: true
  after_create :create_tenant

  OTP_ISSUER = "MyApp"

  def self.generate_otp_secret
    ROTP::Base32.random_base32
  end

  def self.otp_for_secret(secret)
    ROTP::TOTP.new(secret, issuer: OTP_ISSUER)
  end

  def otp
    # ROTP::TOTP.new(otp_secret, issuer: "MyApp")
    self.class.otp_for_secret(otp_secret)
  end

  def valid_otp?(code)
    otp.verify(code, drift_behind: 30)
  end

  def otp_user?
    otp_enabled?
  end

  private

  def generate_device_token
    self.device_token ||= SecureRandom.urlsafe_base64(32)
  end

  def create_tenant
    Apartment::Tenant.create(id.to_s)
  end
end
