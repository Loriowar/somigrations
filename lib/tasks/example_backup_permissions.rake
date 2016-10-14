namespace :somigrations do
  namespace :example do
    namespace :backup do
      namespace :permissions do
        desc 'Grand read permissions on DB with somigration configs to backup user'
        task :grant_readonly_to_backup_role => :environment do
          IndependentScenario::ExampleGrantBackupPermissionsOnDbWithSoconfigToBackupRole.up
        end

        desc 'Revoke read permissions on DB with somigration configs from backup user'
        task :revoke_readonly_to_backup_role => :environment do
          IndependentScenario::ExampleGrantBackupPermissionsOnDbWithSoconfigToBackupRole.down
        end
      end
    end
  end
end