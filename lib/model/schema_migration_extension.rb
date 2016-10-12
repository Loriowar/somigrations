module Model
  class SchemaMigrationExtension < ActiveRecord::Base
    self.table_name = ::CUSTOM_CONFIGURATION.dig(:active_record_object, :table, :schema_migration_extensions)
    self.primary_key = 'version'

    serialize :configuration, Hash
  end
end
