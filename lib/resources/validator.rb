require 'json'
require 'logger'
require 'nokogiri'

class Validator

  def initialize
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::ERROR
  end


  def valid?(input)
    valid_json?(input) ? true : valid_html?(input)
  end

  private

   def valid_json?(input)
      begin
        if input.nil?
          false
        else
          JSON.parse(input)
          true
        end
      rescue JSON::ParserError, TypeError
        @logger.error "This is not valid json or text."
        false
      end
    end

    def valid_html?(input)
      begin
        if input.match(/<!DOCTYPE html>/)
          html = Nokogiri::HTML(input)
          no_errors = html.errors.empty?
          @logger.error "This is not valid html." unless no_errors
          no_errors
        else
          @logger.error "This is not valid html."
          false
        end
      rescue NoMethodError
        @logger.error "This is not valid html."
        false
      end
    end
end