require File.expand_path('../base.rb', __FILE__)

start_at = Time.now
puts "Start the spider at: #{start_at.to_s}"
path=File.join(File.dirname(__FILE__), "spider.rb")
cmd="ruby #{path} 'start' '0' '0' '225678962' 2>/dev/null"
puts cmd
`#{cmd}`

user=User.find(225678962)
us=user.children
arr=[]
us.each do |u|
  arr<< '"'+u.id.to_s+'"'
end
args=arr.join(" ")
cmd="ruby #{path} 'start' '0' '1' #{args}  2>/dev/null"
puts cmd
`#{cmd}`
end_at = Time.now
puts "Got data from renren at: #{end_at.to_s}, used: #{end_at - start_at} seconds"
#5779



