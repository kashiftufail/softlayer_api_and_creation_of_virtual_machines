class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :project_name
      t.string :company_name
      t.boolean :is_activated ,:default => true
      t.integer :admin_id

      t.timestamps
    end
  end
end
