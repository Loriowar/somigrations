module Patch
  module PG
    module Connection
      extend ActiveSupport::Concern

      included do


        class << self
          alias_method :quote_ident_without_function_support, :quote_ident

          def quote_ident(obj)
            if obj =~ /dup/
              obj
            else
              quote_ident_without_function_support(obj)
            end
          end
        end
      end

      #stub

      module ClassMethods

      end
    end
  end
end