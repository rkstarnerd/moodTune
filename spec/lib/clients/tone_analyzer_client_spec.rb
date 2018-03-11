require 'rspec'
require 'json'
require 'clients/tone_analyzer_client'

describe ToneAnalyzerClient do
  before do
    @valid_json   = File.read('spec/helpers/valid.json')
    @valid_text   = File.read('spec/helpers/valid.txt')
    @valid_html   = File.read('spec/helpers/valid.html')
    @valid_mood_html = File.read('spec/helpers/valid_mood.html')

    @client = ToneAnalyzerClient.new
  end

  it 'gets the tone/mood of json' do
    expect(@client.get_mood(@valid_json)).to eq("Analytical")
  end

  it 'gets the tone/mood of text' do
    expect(@client.get_mood(@valid_text)).to eq("Joy")
  end

  it 'get the tone/mood of html' do
    expect(@client.get_mood(@valid_mood_html)).to eq("Confident")
  end

  it 'should raise an error for invalid inputs' do
    invalid_input = [1, 2, "three", "blue"]
    expect { @client.get_mood(invalid_input) }.to raise_error(InvalidInputError)
  end

  it 'should raise an error when no tone/mood is returned' do
    expect { @client.get_mood(@valid_html) }.to raise_error(NoMoodError)
  end
end
