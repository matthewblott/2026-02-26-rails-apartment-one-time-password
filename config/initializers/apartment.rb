Apartment.configure do |config|
  config.excluded_models = %w{ }
  config.tenant_names = -> { User.pluck(:id ) }
end
