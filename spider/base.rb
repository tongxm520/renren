require "rubygems"
require "active_record"
require "yaml"
require "logger"
RAILS_ROOT="/home/simon/Desktop/renren"
Dir["#{RAILS_ROOT}/app/models/*.rb"].each(){|f| require f}

ActiveRecord::Base.establish_connection(YAML.load_file("#{RAILS_ROOT}/config/database.yml")["spider"])

module RenrenSpider
  class Base
    @@log=Logger.new("#{RAILS_ROOT}/log/spider.log", "daily")

    def self.log_info(msg)
      @@log.info(msg)
    end

    def self.log_warn(msg)
      @@log.warn(msg)
    end

    def self.log_error(msg)
      @@log.error(msg)
    end

    def self.show_user
	    puts User.column_names.inspect
	  end
  end
end

if $0==__FILE__
  RenrenSpider::Base.log_info("Computer wins chess game.")
  RenrenSpider::Base.log_warn("AE-35 hardware failure predicted.")
  RenrenSpider::Base.log_error("HAL-9000 malfunction, take emergency action!")
  RenrenSpider::Base.show_user
end



