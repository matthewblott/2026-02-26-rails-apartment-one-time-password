class SharedRecord < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: { writing: :shared, reading: :shared }
end
