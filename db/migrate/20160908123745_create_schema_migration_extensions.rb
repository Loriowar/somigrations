class CreateSchemaMigrationExtensions < PgMigration::V1::Base
  def change
    create_table :schema_migration_extensions, id: false do |t|
      t.string :version, primary_key: true
      t.text :configuration
    end
  end
end
