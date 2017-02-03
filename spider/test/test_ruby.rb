require File.expand_path('../../base.rb', __FILE__)

def output_args(args)
  RenrenSpider::Base.log_info(args.inspect)
end

start_at=Time.now
sleep 20
output_args(ARGV)
end_at=Time.now
RenrenSpider::Base.log_info("used: #{end_at - start_at} seconds")
RenrenSpider::Base.log_info(User.column_names.inspect)
puts "hello world"

#cmd='ruby -w test_ruby.rb "hello" "world" "wonderful" "beautiful"'
#`cmd` 或 Process.spawn(cmd)



