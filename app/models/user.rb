class User < ActiveRecord::Base
  attr_accessible :gender, :birth, :hometown, :address, 
    :school, :level, :crawled,:name,:parent_id,:id
  belongs_to :parent, :class_name=>"User"
  has_many :children,:foreign_key=>:parent_id,:class_name=>"User"
end



