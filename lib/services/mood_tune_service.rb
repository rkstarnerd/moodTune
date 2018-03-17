require 'clients/spotify_client'
require 'clients/gracenote_client'

class MoodTuneService

  def initialize
    @logger        = Logger.new(STDOUT)
    @logger.level  = Logger::INFO
    @spotify_client   = SpotifyClient.new
    @gracenote_client = GracenoteClient.new
  end

  def get_tracks_for_mood(mood, user_id, max_num_playlists, max_num_tracks)
    playlists = @spotify_client.get_user_playlists(user_id, max_num_playlists).shuffle!

    playlist_tracks = nil

    while playlist_tracks.nil?
      playlist = playlists.shift
      playlist_id = @spotify_client.get_playlist_id(playlist.to_json)
      playlist_tracks = @spotify_client.get_playlist_tracks(user_id, playlist_id, max_num_tracks)
    end

    get_playlist_tracks_with_mood(mood, playlist_tracks)
  end

  private

    def get_playlist_tracks_with_mood(mood, playlist_tracks)
      playlist_tracks.select do |track|
        track_mood = @gracenote_client.get_track_mood(track.to_json)
        track if track_mood == mood
      end
    end
end