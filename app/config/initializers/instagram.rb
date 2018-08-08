Instagram.configure do |config|
  config.client_id = ENV.fetch 'IG_CLIENT_ID'
  config.client_secret = ENV.fetch 'IG_CLIENT_SECRET'
  # For secured endpoints only
  config.client_ips = ENV.fetch 'IG_CLIENT_IP'
end
