require 'rspec'
require 'lib/resources/validator'

describe 'Validator' do

  before do
    @validator = Validator.new

    @valid_json   = File.read('spec/helpers/valid.json')
    @invalid_json = File.read('spec/helpers/invalid.json')

    @valid_text   = File.read('spec/helpers/valid.txt')
    @invalid_text = [1, 2, "three", "blue"]

    @valid_html   = File.read('spec/helpers/valid.html')
    @invalid_html = File.read('spec/helpers/invalid.html')
  end

  { @valid_text => true, @invalid_text => false,
    @valid_json => true, @invalid_json => false,
    @valid_html => true, @invalid_html => false, nil => false }.each_pair do |input, result|
    it 'validates input' do
      expect(@validator.valid?(input)).to eq(result)
    end
  end
end