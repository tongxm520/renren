require 'rubygems'
require 'daemons'

args_str=ARGV.inspect
args_str.gsub!(/[\[\]"\s]/,"")
arr=args_str.split(",")
args_arr=[]
args_arr[0]="start"
args_arr[1]="-f"
args_arr[2]="--"
args_arr[3]=arr
args_arr.flatten!
options = {:ARGV=> args_arr,:multiple=>true}
puts File.join(File.dirname(__FILE__), "test_ruby.rb")
Daemons.run(File.join(File.dirname(__FILE__), "test_ruby.rb"), options)
#ruby myserver_control.rb start
#:ARGV  ['start', 'f', '--', 'param1_for_script', 'param2_for_script'].
#ruby myserver_control.rb start --a_switch another_argument
#:ARGV=> ['start', '-f', '--', 'user','topic','friends','wonderful','hardly',args_str]



