module Model
  class SchemaMigrationExtension < ActiveRecord::Base
    self.primary_key = 'version'

    serialize :configuration, Hash
  end
end
