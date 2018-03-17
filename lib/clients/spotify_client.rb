require 'uri'
require 'yaml'
require 'logger'
require 'net/http'

class SpotifyClient
  def initialize
    @config = YAML.load_file('config/config.yml')["spotify"]
    @authorization = @config["base64auth"]
    @logger        = Logger.new(STDOUT)
    @logger.level  = Logger::INFO
  end

  # gets user's first max_num of public playlists
  def get_user_playlists(user_id, max_num_of_playlists)
    uri = URI.parse(@config["base_user_endpoint"] +
                        "#{user_id}/playlists?offset=0&limit=#{max_num_of_playlists}")
    @logger.info "Request uri from get_user_playlists: #{uri}"

    token = get_client_credentials_token
    request = build_get_request(uri, "Bearer #{token}")
    response = get_response(uri, request)

    @logger.info "Response code from get_user_playlists: #{response.code}"
    JSON.parse(response.body)["items"]
  end

  def get_playlist_id(playlist)
    id = JSON.parse(playlist)["id"]
    @logger.info "Playlist id: #{id}"
    id
  end

  def get_playlist_tracks(user_id, playlist_id, max_num_of_tracks)
    uri = URI.parse(@config["base_user_endpoint"] +
                        "#{user_id}/playlists/#{playlist_id}/tracks?offset=0&limit=#{max_num_of_tracks}")
    @logger.info "Request uri get_playlist_tracks: #{uri}"

    token = get_client_credentials_token
    request = build_get_request(uri, "Bearer #{token}")
    response = get_response(uri, request)

    @logger.info "Response code from get_playlist_tracks: #{response.code}"
    JSON.parse(response.body)["items"]
  end

  private

  # uses client_id to prompt user to login and give authorization to access user data
  def get_authorization
    url = @config["authorization_endpoint"]

    params = [["client_id", @config["client_id"]], ["response_type", "code"],
              ["redirect_uri", @config["redirect_uri"]]]

    uri = build_uri(url, params)
    request = build_get_request(uri, "Basic #{@authorization}")
    response = get_response(uri, request)

    @logger.info "Response from get_authorization: response code - #{response.code}, response uri - #{response.body}"
    response
  end

  # uses code returned from get_authorization to get access_token
  def get_authorization_code_token(code)
    url = @config["token_endpoint"]

    params = [["code", code], ["grant_type", "authorization_code"],
              ["redirect_uri", @config["redirect_uri"]]]

    uri = build_uri(url, params)
    request = build_post_request(uri, "Basic #{@authorization}")
    response = get_response(uri, request)

    @logger.info "Response body from get_access_token: #{response.body}"
    response
  end

  # uses client_id and client_secret to get access_token, token_type, expires_in, and scope
  def get_client_credentials_token
    url = @config["token_endpoint"]

    uri = build_uri(url, [])
    request = build_post_request(uri, "Basic #{@authorization}")
    request.set_form_data("grant_type" => "client_credentials")
    response = get_response(uri, request)

    @logger.info "Response body from get_access_token: #{response.body}"
    JSON.parse(response.body)["access_token"]
  end

  def build_uri(url, params)
    uri = URI.parse(url)
    query_params = URI.decode_www_form(uri.query || '')
    params.each { |param| query_params << param }
    uri.query = URI.encode_www_form(query_params)
    uri
  end

  def build_get_request(uri, authorization)
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = authorization
    request
  end

  def build_post_request(uri, authorization)
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = authorization
    request
  end

  def get_response(uri, request)
    req_options = { use_ssl: uri.scheme == "https" }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |https|
      https.request(request)
    end
  end
end