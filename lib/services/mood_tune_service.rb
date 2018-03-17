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
    get_playlist_tracks_with_mood(mood, max_num_tracks, playlists, user_id)
  end

  private

  def get_playlist_tracks(max_num_tracks, playlists, user_id)
    playlist_tracks = nil

    while playlist_tracks.nil?
      playlist = playlists.shuffle.shift
      playlist_id = @spotify_client.get_playlist_id(playlist.to_json)
      playlist_tracks = @spotify_client.get_playlist_tracks(user_id, playlist_id, max_num_tracks)
    end

    playlist_tracks
  end

  def get_playlist_tracks_with_mood(mood, max_num_tracks, playlists, user_id)
    tracks_for_mood = []

    while tracks_for_mood.empty?
      playlist_tracks = get_playlist_tracks(max_num_tracks, playlists, user_id)

      tracks_for_mood =
        playlist_tracks.select do |track|
          track_mood = @gracenote_client.get_track_mood(track.to_json)
          track if track_mood == mood.capitalize
        end
    end

    tracks_for_mood
  end
end