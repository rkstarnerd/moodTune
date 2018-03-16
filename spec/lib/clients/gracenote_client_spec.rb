require 'rspec'
require 'clients/gracenote_client'

describe GracenoteClient do

  it 'gets the mood of a track' do
    track = File.read('spec/helpers/spotify_track_object.json')
    client = GracenoteClient.new
    expect(client.get_track_mood(track)).to be_instance_of String
    expect(client.get_track_mood(track)).to eq('Sensual')
  end
end