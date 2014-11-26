class AddFlagsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :admin, null: false
    end
  end
end

