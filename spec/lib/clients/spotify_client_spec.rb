require 'rspec'
require 'json'
require 'clients/spotify_client'

describe SpotifyClient do

  before do
    @client = SpotifyClient.new
  end

  it 'gets an authorization code' do
    code = "gibberish"
    response = @client.get_authorization_code_token(code)
    expect(response.code).to eq("200")
  end

  it 'gets an auth token with client credentials' do
    token = @client.get_client_credentials_token

    expect(token).to be_instance_of String
  end

  it 'gets a user\'s saved playlists' do
    max_num = Random.rand(10)
    user_playlists = @client.get_user_playlists("rkmyg1", max_num)

    expect(user_playlists.count).to eq(max_num)
  end

  it 'returns the tracks from a playlist' do
    max_num = Random.rand(10)
    @playlist = File.read('spec/helpers/spotify_playlist_object.json')
    playlist_hash = JSON.parse(@playlist)
    playlist_tracks = @client.get_playlist_tracks("rkmyg1", playlist_hash["id"], max_num)

    expect(playlist_tracks.count).to eq(max_num)
  end
end