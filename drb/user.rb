class User
  include DRbUndumped
  attr_accessor :username
end

=begin
comment 'include DRbUndumped'=>

#<DRb::DRbUnknown:0x9c1966c @name="User", @buf="\x04\bo:\tUser\x06:\x0E@usernamei\a">
user_client.rb:6:in `<main>': undefined method `username' for #<DRb::DRbUnknown:0x9c1966c> (NoMethodError)


why? DRbUndumped
Default DRb operation
> pass by value
> Must share code

With DRbUndumped
> pass by reference
> No need to share code

=end
