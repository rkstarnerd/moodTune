require 'json'
require 'rspec'
require 'services/service'
require 'clients/gracenote_client'

describe Service do

  it 'should match mood to tracks in a playlist' do
    tracks = Service.new.get_tracks_for_mood("Sensual", "rkmyg1", 10, 10)
    mood = GracenoteClient.new.get_track_mood(tracks.shuffle.first.to_json)

    expect(mood).to eq("Sensual")
  end
end