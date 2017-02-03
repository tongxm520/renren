class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.integer :path_id
      t.boolean :used

      t.timestamps
    end
  end
end
