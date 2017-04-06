module Patch
  module ActiveRecord
    module ConnectionAdapters
      module PostgreSQLAdapter
        extend ActiveSupport::Concern

        included do

          alias_method :column_definitions_without_function_processing, :column_definitions

          def column_definitions(table_name)
            if table?(table_name)
              column_definitions_without_function_processing(table_name)
            elsif function?(table_name)
              # @todo: alpha-version of query with out args of function; needs to improve
              query(<<-end_sql, 'SCHEMA')
                  SELECT
                      proargname,
                      format_type(proallargtype, atttypmod),
                      expr,
                      attnotnull,
                      proallargtype,
                      atttypmod,
                      collname,
                      comment
                  FROM
                    (SELECT
                        unnest(pp.proargnames) AS proargname,
                        unnest(pp.proallargtypes) AS proallargtype,
                        unnest(pp.proargmodes) AS proargmode,
                        -1 AS atttypmod,
                        null AS expr,
                        False AS attnotnull,
                        null AS collname,
                        null AS comment
                    FROM pg_proc pp
                    INNER JOIN pg_namespace pn ON (pp.pronamespace = pn.oid)
                    INNER JOIN pg_language pl ON (pp.prolang = pl.oid)
                    WHERE pl.lanname NOT IN ('c','internal')
                      AND pn.nspname NOT LIKE 'pg_%'
                      AND pn.nspname <> 'information_schema'
                      AND pp.proname = '#{table_name}') AS p
                  WHERE p.proargmode != 'i';
              end_sql
            else
              raise ::PG::Error, 'Unable to find table/function'
            end

          end

          def table?(table_name)
            begin
              query("SELECT '#{quote_table_name(table_name)}'::regclass")
            rescue ::ActiveRecord::StatementInvalid => e
              if e.message =~ /PG::UndefinedTable/
                []
              else
                raise
              end
            end.any?
          end

          def function?(function_name)
            begin
              query("SELECT '#{quote_function_name(function_name)}'::regproc")
            rescue ::ActiveRecord::StatementInvalid => e
              if e.message =~ /PG::UndefinedFunction/
                []
              else
                raise
              end
            end.any?
          end

          def quote_function_name(function_name)
            quote_table_name(function_name.split('(').first)
          end

          class << self
            # stib
          end
        end

        # stub

        module ClassMethods
          # stub
        end
      end
    end
  end
end