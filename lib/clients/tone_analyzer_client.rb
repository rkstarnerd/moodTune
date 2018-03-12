require 'uri'
require 'json'
require 'yaml'
require 'logger'
require 'net/http'
require 'resources/validator'
require 'helpers/no_mood_error'
require 'helpers/invalid_input_error'

class ToneAnalyzerClient
  def initialize
    @request
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @config       = YAML.load_file('config/config.yml')
  end

  def get_mood(input)
    @logger.info("Input: #{input}")

    response = Validator.new.valid?(input) ? analyze(input) : (raise InvalidInputError)
    tones = JSON.parse(response.body)["document_tone"]["tones"]
    @logger.info("Tones: #{tones}")

    mood = get_max_tone(tones)
    @logger.info("mood: #{mood}")
    mood
  end

  private

    def analyze(input)
      uri = build_uri(input)
      build_request(uri)
      response = get_response(uri)
      @logger.info("response from watson: code - " + response.code + ", body - " + response.body)
      response
    end

    def get_max_tone(tones)
      max_document_tone_score =
          tones.empty? ? (raise NoMoodError) : tones.max_by { |tone| tone["score"] }

      max_document_tone_score["tone_name"]
    end

    def build_request(uri)
      @request = Net::HTTP::Get.new(uri)
      @request.basic_auth(@config["watson"]["username"], @config["watson"]["password"])
    end

    def build_uri(input)
      uri_input = build_uri_input(input)
      uri_string = URI.escape(@config["watson"]["base_url"] + "#{uri_input}")
      uri = URI.parse(uri_string)
      @logger.info("uri: " + uri.to_s)
      uri
    end

    def build_uri_input(input)
      begin
        text = JSON.parse(input)["text"]
        text.nil? ? input : text
      rescue JSON::ParserError
        input
      end
    end

    def get_response(uri)
      req_options = { use_ssl: uri.scheme == "https", }

      Net::HTTP.start(uri.hostname, uri.port, req_options) do |https|
        https.request(@request)
      end
    end
end
