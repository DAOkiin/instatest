class IgService
  IG_BASE_URL = 'https://api.instagram.com'.freeze

  attr_reader :client

  def self.request_token_with(code)
    HTTParty.post(
      "#{IG_BASE_URL}/oauth/access_token",
      body: { 'client_id' => ENV.fetch('IG_CLIENT_ID'),
              'client_secret' => ENV.fetch('IG_CLIENT_SECRET'),
              'grant_type' => 'authorization_code',
              'redirect_uri' => ENV.fetch('CALLBACK_URL'),
              'code' => code },
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded',
                 'Accept' => 'application/json' }
    )
  end

  def self.user_account_data(token)
    HTTParty.get(
      "#{IG_BASE_URL}/v1/users/self/?access_token=#{token}")
  end

  def initialize(access_token:)
    @client = Instagram.client(access_token: access_token)
  end

  def user_media
    @client.user_recent_media
  end

  private

  def days_ago(timestamp)
    (Date.now - Date.strptime(timestamp, '%s')).to_i
  end

  def generate_sig(endpoint, params, secret)
    sig = endpoint
    params.sort.map do |key, val|
      sig += format('|%s=%s', key, val)
    end
    digest = OpenSSL::Digest::Digest.new('sha256')
    OpenSSL::HMAC.hexdigest(digest, secret, sig)
  end

  def actual_tags_for(location)
    cords = convert_to_coordinates(location)
    locations = @client.location_search(cords[0], cords[1], '500')
    locations.map do |l|
      @client.location_recent_media(l.id.to_i)
    end
  end

  def convert_to_coordinates(location)
    Geocoder.configure(lookup: :yandex)
    Geocoder.search(location).first.coordinates
  end
end
