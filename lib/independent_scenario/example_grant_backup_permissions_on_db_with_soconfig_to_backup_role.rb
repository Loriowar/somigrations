module IndependentScenario
  class ExampleGrantBackupPermissionsOnDbWithSoconfigToBackupRole
    include PgMigration::V1::BaseModule

    class << self
      def up(*args)
        new(*args).up
      end

      def down(*args)
        new(*args).down
      end
    end

    def initialize(options = {})
      @options = {
          db_alias: :default,
          role_alias: :superuser,
          single_transaction: true
      }.with_indifferent_access.merge(options).
                                merge(disable_stash_config: true,
                                      disable_fetch_config: true)
    end

    def up
      within_up(@options) do
        execute <<-SQL
          GRANT SELECT ON ALL TABLES    IN SCHEMA public TO #{value_for('db.role.backuper')};
          GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO #{value_for('db.role.backuper')};
        SQL
      end
    end

    def down
      within_down(@options) do
        execute <<-SQL
          REVOKE SELECT ON ALL TABLES    IN SCHEMA public FROM #{value_for('db.role.backuper')};
          REVOKE SELECT ON ALL SEQUENCES IN SCHEMA public FROM #{value_for('db.role.backuper')};
        SQL
      end
    end
  end
end
