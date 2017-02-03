require File.expand_path('../../base.rb', __FILE__)

if $0==__FILE__
  RenrenSpider::Base.show_user
  puts RAILS_ROOT
  puts Relationship.column_names.inspect
end

