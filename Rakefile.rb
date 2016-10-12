require 'pry'

require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

# @hack: sort require for load 'base' firstly
# Dir.glob('lib/pg_migration/v1/**/*.rb').sort.each {|r| require File.expand_path(r, File.dirname(__FILE__))}
require 'pg_migration/v1/base'

# @note: config must be loaded before setup of AR parameters and before require modules
# @note: for separate default values (which contain most part of parameters) from custom part (with less part of parameters)
#        we use two config files and merge them, otherwise we can't make a deep merge or redefine certain keys inside an array
#        within a single yml file
CUSTOM_CONFIGURATION =
    YAML.load_file(File.dirname(__FILE__) + '/db/default_soconfig.yml').
        with_indifferent_access.
        deep_merge(
        YAML.load_file(File.dirname(__FILE__) + '/db/custom_soconfig.yml').with_indifferent_access[Rails.env]
    )

# @note: in model used values from config
# Dir.glob('model/**/*.rb').each {|r| require r}
require 'model/schema_migration_extension'

ActiveRecord::Base.schema_format = :sql
# @note: alternative table name for AR table with information about migration; aim: prevent intersection with default one
ActiveRecord::Base.schema_migrations_table_name = CUSTOM_CONFIGURATION.dig(:active_record_object, :table, :schema_migrations)
# @note: disable foolproof, appeared in Rails 5: https://github.com/rails/rails/pull/22967
ActiveRecord::Base.internal_metadata_table_name = CUSTOM_CONFIGURATION.dig(:active_record_object, :table, :internal_metadata_table_name)
ActiveRecord::Base.protected_environments = CUSTOM_CONFIGURATION.dig(:active_record_object, :option, :protected_environments)
