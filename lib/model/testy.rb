module Model
  class Testy < ActiveRecord::Base
    self.table_name = 'dup(42)'
    # self.abstract_class = true
    arel_table.instance_variable_set(:@table_alias, 'simple_dup')

    def readonly?
      true
    end

    def quoted_table_name
      'dup()'
    end

    def quote_table_name(name)
      name
    end

    def quote_column_name(name)
      name
    end
  end
end
