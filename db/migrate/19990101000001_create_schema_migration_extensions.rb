# This is a strictly required migration. It create table for storage of all further soconfig.
class CreateSchemaMigrationExtensions < PgMigration::V1::Base
  def change
    create_table CUSTOM_CONFIGURATION.dig(:active_record_object, :table, :schema_migration_extensions), id: false do |t|
      t.string :version, primary_key: true
      t.text :configuration
    end
  end
end
