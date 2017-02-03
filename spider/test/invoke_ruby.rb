start_at=Time.now

path=File.join(File.dirname(__FILE__), "test_ruby.rb")
arr=[]
20.times do |i|
  r=Random.rand(10000000)+10000000
  arr << '"'+r.to_s+'"'
end
args=arr.join(" ")
cmd="ruby  #{path} #{args}"
puts cmd

`#{cmd}`
#Process.spawn(cmd)

end_at=Time.now
puts "used: #{end_at - start_at} seconds"


