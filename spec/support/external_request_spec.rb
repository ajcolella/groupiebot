require 'spec_helper'

feature 'External request' do
  it 'queries the Twitter API' do
    uri = URI('https://api.twitter.com/1.1')

    response = Net::HTTP.get(uri)

    expect(response).to be_an_instance_of(String)
  end
end