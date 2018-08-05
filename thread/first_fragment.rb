require 'net/http'

# Our sample set of currencies
currencies = ['ARS','AUD','CAD','CNY','DEM','EUR','GBP','HKD','ILS','INR','USD','XAG','XAU']
currencies.each do |currency|
  puts Net::HTTP.get("download.finance.yahoo.com","/d/quotes.csv?e=.csv&amp;f=sl1d1t1&amp;s=USD#{currency}=X")
end

puts "DONE!"


