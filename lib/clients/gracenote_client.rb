require 'uri'
require 'yaml'
require 'json'
require 'rexml/document'
require 'logger'
require 'net/http'
require 'nokogiri'

class GracenoteClient
  def initialize
    @config = YAML.load_file('config/config.yml')["gracenote"]
    @logger        = Logger.new(STDOUT)
    @logger.level  = Logger::INFO
  end

  def get_track_mood(track)
    track_details = JSON.parse(track)["track"]

    unless track_details == nil
      artist_name = track_details["artists"][0]["name"]
      album_name  = track_details["album"]["name"]
      track_name  = track_details["name"]
      @logger.info("\n\nArtist name: #{artist_name}, Album name: #{album_name}" + " Track name: #{track_name}")

      xml_query = build_query(artist_name, album_name, track_name)
      @logger.info("XML query: #{xml_query}")

      uri = URI.parse(@config["base_url"])
      request  = build_request(uri, xml_query)
      response = get_response(uri, request)

      @logger.info("Response code from get_track_mood: #{response.code}")

      mood = parse_mood(response.body)
      @logger.info("Mood: #{mood}")
      mood
    else
      @logger.info "\n\nThere are no details to obtain mood for #{track}."
    end
  end

  def build_query(artist_name, album_name, track_name)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.queries{
        xml.AUTH{
          xml.CLIENT @config["client_id"]
          xml.USER   @config["user_id"]
        }
        xml.QUERY('CMD' => 'ALBUM_SEARCH'){
          xml.MODE 'SINGLE_BEST_COVER'
          xml.TEXT_('TYPE' => 'ARTIST') {
            xml.text artist_name
        }
          xml.TEXT_('TYPE' => 'ALBUM_TITLE'){
            xml.text album_name
          }
          xml.TEXT_('TYPE' => 'TRACK_TITLE'){
            xml.text track_name
          }
          xml.OPTION{
            xml.PARAMETER 'SELECT_EXTENDED'
            xml.VALUE 'MOOD'
          }
          xml.OPTION{
            xml.PARAMETER 'SELECT_DETAIL'
            xml.VALUE 'MOOD:1LEVEL'
          }
        }
      }
    end

    builder.to_xml
  end

  def build_request(uri, xml)
    request = Net::HTTP::Post.new uri.path
    request.body = xml
    request.content_type = 'text/xml'
    request
  end

  def get_response(uri, request)
    req_options = { use_ssl: uri.scheme == "https" }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |https|
      https.request(request)
    end
  end

  def parse_mood(response_body)
    doc = REXML::Document.new(response_body)
    mood = doc.root.elements["RESPONSE"].elements["ALBUM"].elements["TRACK"].elements["MOOD"]
    mood.nil? ? (@logger.info("No response/mood for this track.")) : mood.text
  end
end