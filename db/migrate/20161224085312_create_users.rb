class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :gender
      t.string :birth
      t.string :hometown
      t.string :address
      t.string :school
      t.integer :level #0=>我,1=>我的好友,2=>好友的好友,3=>好友的好友的好友
      t.boolean :crawled, :default=>false  #是否抓取了相关好友
      t.integer :parent_id
      t.string :name
      t.boolean :dispatched, :default=>false

      t.timestamps
    end
  end
end
