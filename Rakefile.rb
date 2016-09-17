require 'pry'

require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

# @hack: sort require for load 'base' firstly
# Dir.glob('lib/pg_migration/v1/**/*.rb').sort.each {|r| require File.expand_path(r, File.dirname(__FILE__))}
require 'pg_migration/v1/base'

# Dir.glob('model/**/*.rb').each {|r| require r}
require 'model/schema_migration_extension'

ActiveRecord::Base.schema_format = :sql

CUSTOM_CONFIGURATION =
    YAML.load_file(File.dirname(__FILE__) + '/db/custom_configuration.yml').with_indifferent_access