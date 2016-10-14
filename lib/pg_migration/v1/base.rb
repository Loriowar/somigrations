module PgMigration
  module V1
    class Base < ActiveRecord::Migration[5.0]
      include BaseModule
    end
  end
end
