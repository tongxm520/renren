require 'uri'
require 'cgi'
require 'json'
require File.expand_path('../base.rb', __FILE__)

module RenrenSpider
  class Spider < Base
    PAGE_SIZE=24

    def initialize(output_path,max_level,ids)
      @output_path="#{RAILS_ROOT}/spider/output/#{output_path}"
      @max_level=max_level.to_i
      @ids=ids
    end

		def curl(headers_txt, target, post_data = nil,cookie=nil,output_file=nil,output=nil)
			header_param = headers_txt.split("\n").map {|header| "-H \"#{header}\""}.join(' ')

			cmd = "curl #{header_param}"
			cmd += " -d \"#{post_data}\"" if post_data
			cmd += " -b \"#{cookie}\"" if cookie
			cmd += " -c \"#{output_file}\"" if output_file
			cmd += " \"#{target}\" --compressed"
			if output
				cmd += " >#{output}"
			else
				cmd += " 2>/dev/null"
			end
		
			puts "Execute:\n#{cmd}"
			2.times {puts}

			`#{cmd}`
		end

		def generate_cookie(cookie_file,hash_added)
			hash={}
			File.open(cookie_file,"r").each_line do |line|
				if line!="" and line=~/^[^#]/
					arr=line.split(/\s/)
					hash[arr[-2]]=arr[-1] unless arr.empty?
				end   
			end
			hash.merge!(hash_added)
			puts hash
			array=[]
			if hash["societyguester"]
				hash["t"]=hash["societyguester"]
			end
			hash.each_pair do |key,value|
				array << key.to_s+"="+value.to_s
			end
			array.join(";")
		end

		def encoded_post_body(body)
			pairs=body.strip.split('&')
			encoded = pairs.map do |pair_txt|
			pair = pair_txt.split('=')
				"#{pair[0]}=#{CGI.escape(pair[1]) rescue ''}"
			end.join('&')
			encoded
		end

		def fetch_cookie
			sys_home_header = <<-EOF
			Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
			Accept-Encoding: gzip, deflate
			Accept-Language: en-US,en;q=0.5
			Connection: keep-alive
			Host: www.renren.com
			User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0
			EOF

			sys_home_target="http://www.renren.com/SysHome.do"
			sys_home_cookie="#{@output_path}/sys_home_cookie"
			sys_home_output="#{@output_path}/sys_home.html"
			curl(sys_home_header,sys_home_target,nil,nil,sys_home_cookie,sys_home_output)

			icode_header= <<-EOF
			Accept: image/png,image/*;q=0.8,*/*;q=0.5
			Accept-Encoding: gzip, deflate
			Accept-Language: en-US,en;q=0.5
			Connection: keep-alive
			Host: icode.renren.com
			Referer: http://www.renren.com/SysHome.do
			User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0
			EOF
			icode_target="http://icode.renren.com/getcode.do?t=web_login&rnd=Math.random()"
			sys_home_cookie_input= generate_cookie(sys_home_cookie,{})
			ick_login_file="#{@output_path}/ick_login_file"
			stuff=curl(icode_header,icode_target,nil,sys_home_cookie_input,ick_login_file)
			File.open("#{@output_path}/captchaData.jpg", 'w') do |file|
				file.write(stuff)
			end
			puts "Please view the captcha image manually from /tmp/captchaData.jpg, and type the txt below."
			start_at = Time.now
			puts "Got the captcha image from server at: #{start_at.to_s}"
			#captcha_code = gets
			captcha_code = ""
			puts "Got captcha_code:\n#{captcha_code}"
			end_at = Time.now
			puts "Got captcha_code from user at: #{end_at.to_s}, used: #{end_at - start_at} seconds"

			3.times{puts}
			puts '##################################################'


			jebe_target="http://xray.jebe.renren.com/xray/cookie/getjebekey.htm?uid=0&callback=reqCall"
			jebe_key_file="#{@output_path}/jebe_key"
			jebe_header = <<-EOF
			Accept: */*
			Accept-Encoding: gzip, deflate
			Accept-Language: en-US,en;q=0.5
			Connection: keep-alive
			Host: xray.jebe.renren.com
			Referer: http://www.renren.com/SysHome.do
			User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0
			EOF

			#ick_login=8124295d-b79a-4102-922d-f3992a004b79
			ick_login_str=generate_cookie(ick_login_file,{})
			sys_home_cookie_str= [sys_home_cookie_input,ick_login_str].join(";")
			curl(jebe_header,jebe_target,nil,sys_home_cookie_str,jebe_key_file)

			encrypt_key_target="http://login.renren.com/ajax/getEncryptKey"
			encrypt_key_header= <<-EOF
			Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
			Accept-Encoding: gzip, deflate
			Accept-Language: en-US,en;q=0.5
			Connection: keep-alive
			Content-Type: application/x-www-form-urlencoded
			Host: login.renren.com
			Referer: http://login.renren.com/ajaxproxy.htm
			User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0
			X-Requested-With: XMLHttpRequest
			EOF
			encrypt_key_output="#{@output_path}/encrypt_key"
			curl(encrypt_key_header,encrypt_key_target,nil,sys_home_cookie_str,nil,encrypt_key_output)

			rkey=nil
			File.open(encrypt_key_output,"r").each_line do |line|
				if line=~/rkey/
					h=JSON.parse(line)
					rkey=h["rkey"]
				end
			end
			#s=%Q({"isEncrypt":true,"e":"10001",
			#"n":"9f4ef664e6eb5f6660f5ef0263291ef986cc9891b160a4de27e17c2755ebda0b",
			#"maxdigits":"19","rkey":"5e0b20645efb740942b773a52d118eb9"})
			#puts "rkey=#{rkey}"


			rkey="5b625fd2e7bb436f20f4c7905430b4e1"
			password="281d28f3f911ac208cacd296927f69ddbbf621ed5b94774a3f16e23845d46284"
			#rkey与password必须一致


			login_target="http://www.renren.com/ajaxLogin/login?1=1&uniqueTimestamp=20161151634435"
			login_header= <<-EOF
			Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
			Accept-Encoding: gzip, deflate
			Accept-Language: en-US,en;q=0.5
			Connection: keep-alive
			Content-Type: application/x-www-form-urlencoded
			Host: www.renren.com
			Referer: http://www.renren.com/SysHome.do
			User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0
			X-Requested-With: XMLHttpRequest
			EOF

			post_body = <<-EOF
			email=tongxiaoming520@163.com&icode=#{captcha_code}&origURL=http://www.renren.com/home&domain=renren.com&key_id=1&captcha_type=web_login&password=#{password}&rkey=#{rkey}&f=http://www.renren.com/225678962
			EOF

			encoded_post_body=encoded_post_body(post_body)

			jebe_key_str=generate_cookie(jebe_key_file,{"wp_fold"=>"0"})
			login_input_cookie=[sys_home_cookie_str,jebe_key_str].join(";")
			#puts login_input_cookie
			login_de="#{@output_path}/login_de"
			login_result="#{@output_path}/login_result"
			curl(login_header, login_target, encoded_post_body,login_input_cookie,login_de,login_result)

			otherfriends_cookie=[login_input_cookie,generate_cookie(login_de,{"ver"=>"7.0","loginfrom"=>"null"})].join(";")
			#puts "otherfriends_cookie:#{otherfriends_cookie}"
			otherfriends_cookie
		end

		def get_other_friends_data(_cookie,id,request_token,_rtk,pn=0,pz=PAGE_SIZE)
			data_target="http://friend.renren.com/friend/api/getotherfriendsdata"
			data_header= <<-EOF
			Accept: application/json, text/javascript, */*; q=0.01
			Accept-Encoding: gzip, deflate
			Accept-Language: en-US,en;q=0.5
			Connection: keep-alive
			Content-Type: application/x-www-form-urlencoded; charset=UTF-8
			Host: friend.renren.com
			Referer: http://friend.renren.com/otherfriends?id=#{id}
			User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0
			x-requested-with: XMLHttpRequest
			EOF

			data_body = <<-EOF
			p={"fid":"#{id}","pz":"#{pz}","type":"WEB_FRIEND","pn":"#{pn}"}&requestToken=#{request_token}&_rtk=#{_rtk}
			EOF
			#puts data_body
			encoded_data_body=encoded_post_body(data_body)
			#data_output="/home/simon/Desktop/relationship/data_output"
			otherfriendsdata=curl(data_header, data_target, encoded_data_body,_cookie,nil)
			JSON.parse(otherfriendsdata)
		end

		#id=225678962
		def get_other_friends(other_cookie,id)
			otherfriends_target="http://friend.renren.com/otherfriends?id=#{id}"
			otherfriends_header= <<-EOF
			Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
			Accept-Encoding: gzip, deflate
			Accept-Language: en-US,en;q=0.5
			Connection: keep-alive
			Host: friend.renren.com
			User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0
			EOF

			#otherfriends_output="/home/simon/Desktop/relationship/otherfriends.html"
			page=curl(otherfriends_header,otherfriends_target,nil,other_cookie,nil)
			nx_user=page.scan(/nx\.user\s=\s\{(.+?)\};/im)
			user_info=nx_user[0][0].gsub!(/[\r\n\t"\s]/,"").split(",").inspect
			user_hash={}
			user_info.gsub!(/["'\[\]]/,"")
			#puts user_info
			user_info.split(",").each do |i|
				i.gsub!(/\s/,"")
				arr=i.split(":")
				if arr[0]=="tinyPic"
					user_hash[arr[0]]=arr[1]+":"+arr[2]
				else
					user_hash[arr[0]]=arr[1]
				end
			end
			#puts user_hash

			otherfriends_hash=get_other_friends_data(other_cookie,id,user_hash["requestToken"],user_hash["_rtk"])

			#puts otherfriends_hash["data"]["total"]
			#puts otherfriends_hash["data"]["friends"]

			count=(otherfriends_hash["data"]["total"].to_i/PAGE_SIZE.to_f).ceil
			more_friends=[otherfriends_hash["data"]["friends"]]
			count.times do |t|
				if t>0
					hash=get_other_friends_data(other_cookie,id,user_hash["requestToken"],user_hash["_rtk"],t)
					more_friends << hash["data"]["friends"]
				end
			end
			more_friends.flatten!.compact!
			more_friends
		end

		#id=203007449
		def get_profile(cookie,id)
			target="http://www.renren.com/#{id}/profile"
			header= <<-EOF
			Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
			Accept-Encoding: gzip, deflate
			Accept-Language: en-US,en;q=0.5
			Connection: keep-alive
			Host: www.renren.com
			User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0
			EOF
			page=curl(header, target,nil,cookie)
			info= page.scan(/<div\sclass="tl-information">(.+?)<\/div>/im)[0]
		
			if info && info[0]
				school_info=info[0].scan(/<li\sclass="school">(.+?)<\/li>/im)[0]
				school=nil
				school=school_info[0].scan(/<span>(.+?)<\/span>/im)[0] if school_info&&school_info[0]
				school=school[0].gsub!(/就读于/,"") if school&&school[0]
				school=school.to_s

				birthday_info=info[0].scan(/<li\sclass="birthday">(.+?)<\/li>/im)[0]
				if birthday_info&&birthday_info[0]
					birthday=birthday_info[0].scan(/<span>(.+?)<\/span>/im)
				  gender=nil
					gender=birthday[0][0] if birthday[0][0]
				  gender=gender.to_s
				  birth=nil
					birth=birthday[1][0].gsub!(/[，\s]/,"") if birthday[1][0]
				  birth=birth.to_s
				end

				hometown_info=info[0].scan(/<li\sclass="hometown">(.+?)<\/li>/im)[0]
				hometown=nil
				hometown=hometown_info[0].gsub!(/来自/,"").gsub!(/\s/,"") if hometown_info&&hometown_info[0]
				hometown=hometown.to_s

				address_info=info[0].scan(/<li\sclass="address">(.+?)<\/li>/im)[0]
				address=nil
				address=address_info[0].split(/\s/)[1] if address_info&&address_info[0]
				address=address.to_s
			end
			{"school"=>school,"gender"=>gender,"birth"=>birth,"hometown"=>hometown,"address"=>address}
		end

    def save_data(id)
      id=id.to_i
      otherfriends_cookie=fetch_cookie
      h=get_profile(otherfriends_cookie,id)
      begin
				u = User.find(id)
			rescue ActiveRecord::RecordNotFound => e
				u = nil
			end

      unless u
        level=0
      else
        level=u.level
      end

      if u
        u.update_attributes(h)
      else
        user=User.new(h.merge!({:id=>id,:name=>"童小明",:parent_id=>0,:crawled=>true,:level=>level}))
        user.save
      end

      user=User.find(id)
      if level>=0&&level<=@max_level
        friends=get_other_friends(otherfriends_cookie, id)
        friends.each do |f|
          exist_user=User.find(f["fid"].to_i) rescue nil
          unless exist_user
		        u=User.new
		        u.name=f["fname"]
		        u.id=f["fid"]
		        u.parent_id=id
		        u.crawled=false
            u.dispatched=false
		        u.level=user.level+1
						u.save
          end
          exist_r1=Relationship.find_by_from_id_and_to_id(id,f["fid"].to_i)
          exist_r2=Relationship.find_by_from_id_and_to_id(f["fid"].to_i,id)
          if exist_r1.nil? and exist_r2.nil?
		        r=Relationship.new
		        r.from_id=id
		        r.to_id=f["fid"]
		        r.save
          end
				end
      end

      user.crawled=true
      user.dispatched=true
      user.save 
      Spider.log_info("#{id} crawled")
    end

    def fetch_all
      @ids.each do |id|
        save_data(id)
      end
    end
  end
end

#ruby  spider.rb "start" "0" "0" "225678962"
#ruby  spider.rb 'start' '0' '1' "172761669" "192860279" "203007449" "221577285" "221963503" "222648676" "222884794" "222975256" "223324956" "223815304" "223835903" "224519368" "225628911" "225672305" "226207451" "227244031" "227312786" "227815179" "228939070" "229613938" "230721405" "230919293" "230954916" "231055470" "231894434" "234933158" "237073635" "237682298" "238754125" "239289989" "241256491" "241562859" "257617073" "262089494" "268093250" "268916795" "282011139" "286630451" "288666170" "290065405" "290696944" "327723693" "328054094" "337628501" "344115076" "344128589" "415327804" "859689226"

if $0==__FILE__
	start_at = Time.now
	puts "Start the spider at: #{start_at.to_s}"
	s=RenrenSpider::Spider.new(ARGV[1],ARGV[2],ARGV[3..-1])
  s.fetch_all
	end_at = Time.now
	puts "Got data from renren at: #{end_at.to_s}, used: #{end_at - start_at} seconds"
end

=begin
<div class="tl-information">
<ul><li class="school"><span>就读于武汉商贸学院</span></li>
<li class="birthday">
<span>男生</span> <span>，12月13日</span></li>
<li class="hometown">来自湖北荆州市</li></ul></div>


<div class="tl-information">
<ul>
<li class="birthday">
<span>男生</span> <span>，6月12日</span></li>
<li class="hometown">来自浙江宁波市</li>
<li class="address">现居 宁波市</li></ul></div>


<div class="tl-information">
<ul><li class="school"><span>就读于武汉商贸学院</span></li>
<li class="birthday">
<span>女生</span> <span>，8月20日</span></li>
<li class="hometown">来自湖北宜昌市</li>
<li class="address">现居 宜昌市</li></ul></div>
=end





