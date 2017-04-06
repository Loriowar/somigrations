namespace :somigrations do
  namespace :backup do
    namespace :permissions do
      desc 'Выдача прав доступа на чтение к БД с конфигами somigrations пользователю, от имени которого выполняются бэкапы'
      task :grant_readonly_to_backup_role => :environment do
      # begin
        PGconn.send(:include, Patch::PG::Connection) unless PGconn.included_modules.include? Patch::PG::Connection
        ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send(:include, Patch::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) unless ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.included_modules.include? Patch::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        # Model::Testy.arel_table.instance_variable_set(:@table_alias, 'simple_dup')
        binding.pry
        Model::Testy.find_by_sql(["select * from dup(:id)", { id: 42 }])
        Model::Testy.reorder('').first
      # rescue
      #   puts $@
      # end
      # IndependentScenario::GrantBackupPermissionsOnDbWithSoconfigToBackupRole.up
      end

      desc 'Изъятие прав доступа на чтение к БД с конфигами somigrations у пользователя, от имени которого выполняются бэкапы'
      task :revoke_readonly_to_backup_role => :environment do
        IndependentScenario::GrantBackupPermissionsOnDbWithSoconfigToBackupRole.down
      end
    end
  end
end