require 'json'
require 'rspec'
require 'services/mood_tune_service'
require 'clients/gracenote_client'

describe MoodTuneService do

  it 'should match mood to tracks in a playlist' do
    moods = File.read('spec/helpers/moods.txt').lines.shuffle
    input_mood = moods.first.strip.capitalize
    tracks = MoodTuneService.new.get_tracks_for_mood(input_mood, "1214851524", 10, 10)
    mood = GracenoteClient.new.get_track_mood(tracks.shuffle.first.to_json)

    expect(mood).to eq(input_mood)
  end
end