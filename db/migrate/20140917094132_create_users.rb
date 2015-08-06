class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.attachment :document

      t.timestamps
    end
  end
end
