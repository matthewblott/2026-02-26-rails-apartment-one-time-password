class User < AuthRecord
  has_many :sessions, dependent: :destroy

  before_validation :generate_device_token, on: :create

  validates :device_token, presence: false, uniqueness: true, allow_nil: true
  validates :email, presence: false, uniqueness: true, allow_nil: true

  after_create :create_tenant

  def otp
    ROTP::TOTP.new(otp_secret, issuer: "MyApp")
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
