class User < AuthRecord
  has_many :sessions, dependent: :destroy
  before_validation :generate_device_token, on: :create
  validates :device_token, presence: false, uniqueness: true, allow_nil: true
  validates :email, presence: false, uniqueness: true, allow_nil: true
  after_create :create_tenant
  after_destroy :drop_tenant

  OTP_ISSUER = "MyApp"

  def self.generate_otp_secret
    ROTP::Base32.random_base32
  end

  def self.otp_for_secret(secret)
    ROTP::TOTP.new(secret, issuer: OTP_ISSUER)
  end

  def otp
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

  def drop_tenant
    checkpoint_wal
    Apartment::Tenant.drop(id.to_s)
    cleanup_wal_files
  end

  def tenant_db_path
    # Adjust this to however your tenant DB paths are configured.
    # If you're using Apartment's default SQLite adapter, tenant files
    # usually live in the same directory as your other SQLite DBs.
    Rails.root.join("storage", Rails.env, "#{id}.sqlite3").to_s
  end

  def checkpoint_wal
    # Only checkpoint if we can actually connect to the tenant DB
    Apartment::Tenant.switch(id.to_s) do
      ActiveRecord::Base.connection.execute("PRAGMA wal_checkpoint(TRUNCATE)")
    end
  rescue ActiveRecord::ActiveRecordError, SQLite3::Exception
    # Tenant DB might already be in a weird state; don't block the drop
    nil
  end

  def cleanup_wal_files
    %w[-wal -shm].each do |suffix|
      path = "#{tenant_db_path}#{suffix}"
      File.delete(path) if File.exist?(path)
    end
  end

end
