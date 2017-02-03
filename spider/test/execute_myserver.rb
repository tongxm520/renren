start_at=Time.now
path=File.join(File.dirname(__FILE__), "myserver_control.rb")

10.times do
	arr=[]
	20.times do |i|
		r=Random.rand(10000000)+10000000
		arr << r
	end
	args=arr.join(" ")
	cmd="ruby #{path} start #{args}"
  puts cmd
	`#{cmd}`
end

end_at=Time.now

puts "used: #{end_at - start_at} seconds"

