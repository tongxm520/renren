class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.text :ids
      t.integer :total
      t.integer :crawled
      t.boolean :finished
      t.string :percentage      
      t.time :start_at
      t.time :finish_at
      t.integer :used

      t.timestamps
    end
  end
end
