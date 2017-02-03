class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :from_id
      t.integer :to_id

      t.timestamps
    end
    #add a foreign key  
    execute "ALTER TABLE relationships ADD CONSTRAINT fk_relationships_users_a FOREIGN KEY (from_id) REFERENCES users(id)"
    
    execute "ALTER TABLE relationships ADD CONSTRAINT fk_relationships_users_b FOREIGN KEY (to_id) REFERENCES users(id)"
    
    add_index "relationships", ["from_id"], :name => "index_relationships_on_from_id"
    add_index "relationships", ["to_id"], :name => "index_relationships_on_to_id"
  end
end
