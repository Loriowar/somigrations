module PgMigration
  module V1
    class Base < ActiveRecord::Migration[5.0]

      # @description: all magic with blocks needed for eval raw-sql within different DBs

      # @todo: Need processing of errors and exceptions everywhere

      # @note: instance_eval &bloc instead of block.call is very important

      # around methods

      def within_database(db_alias = :default, &block)
        old_db_config = marshal_dup(ActiveRecord::Base.connection_config).with_indifferent_access
        db_name = migration_config[:db][:name][db_alias]
        new_db_config = old_db_config.merge({database: db_name})

        StrangeModel.establish_connection(new_db_config)
        @strange_delegator = StrangeDelegator.new(StrangeModel.connection, self)

        within_delegator &block
      end

      def within_role(role_alias = :superuser, &block)
        db_role = migration_config[:db][:role][role_alias]
        within_delegator do
          old_role = execute('SELECT current_role;').getvalue(0, 0)
          execute "SET ROLE #{db_role};"
          block.call
          execute "SET ROLE #{old_role};"
        end
      end

      def within_stash_config(&block)
        block.call
        ::Model::SchemaMigrationExtension.create(version: version, configuration: migration_config)
      end

      def within_fetch_config(&block)
        @migration_config = ::Model::SchemaMigrationExtension.where(version: version).first.configuration.with_indifferent_access
        block.call
        ::Model::SchemaMigrationExtension.where(version: version).destroy_all
      end

      def within_transaction(&block)
        target_model = @strange_delegator.nil? ? ::ActiveRecord::Base : StrangeModel

        within_delegator do
          target_model.transaction do
            instance_eval &block
          end
        end
      end

      def within_up(options = {}, &block)
        default_options =
            {
                db_alias: :default,
                role_alias: :superuser,
                single_transaction: true
            }.with_indifferent_access
        working_options = default_options.merge(options)

        within_stash_config do
          within_database(working_options[:db_alias]) do
            within_role(working_options[:role_alias]) do
              if working_options[:single_transaction]
                within_transaction do
                  instance_eval &block
                end
              else
                instance_eval &block
              end
            end
          end
        end
      end

      def within_down(options = {}, &block)
        default_options =
            {
                db_alias: :default,
                role_alias: :superuser,
                single_transaction: true
            }.with_indifferent_access
        working_options = default_options.merge(options)

        within_fetch_config do
          within_database(working_options[:db_alias]) do
            within_role(working_options[:role_alias]) do
              if working_options[:single_transaction]
                within_transaction do
                  instance_eval &block
                end
              else
                instance_eval &block
              end
            end
          end
        end
      end

      # helper methods

      # @todo: need to extract version from full class name instead of hardcode
      def migration_config
        @migration_config ||= ::CUSTOM_CONFIGURATION[:v1]
      end

      # dot-separated string like 'schema.main' without version specifying
      def value_for(scope)
        migration_config.dig(*scope.split('.'))
      end

      def marshal_dup(obj)
        Marshal.load(Marshal.dump(obj))
      end

      def within_delegator(&block)
        if @strange_delegator.nil?
          block.call
        else
          @strange_delegator.instance_eval(&block)
        end
      end
    end

    # @todo: move out below classes

    # @todo: maybe needs to undef all methods or use Delegator/Forwardable classes from Ruby
    class StrangeDelegator
      def initialize(connection, scope)
        @connection = connection
        @scope = scope
      end

      def execute(*args)
        puts args
        @connection.execute(*args)
      end

      def method_missing(name, *args, &block)
        if @scope.respond_to? name
          @scope.send(name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        @scope.respond_to?(name) || super
      end
    end

    class StrangeModel < ActiveRecord::Base; end
  end
end
