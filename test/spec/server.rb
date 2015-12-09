require_relative './spec_init'

describe 'Server' do
  specify 'Request and Response' do
    counter = 1

    HTTP::Server::Controls::ExampleServer.run do |port, scheduler|
      uri = URI::HTTP.build :host => 'localhost', :port => port, :path => '/countdown'
      connection = HTTP::Commands::Connect.(uri, scheduler: scheduler)

      while counter > 0
        entity = { 'counter' => counter }
        json = JSON.pretty_generate entity

        response = HTTP::Commands::Post.(json, uri, connection: connection)
        fail unless response.status_code == 201

        response = HTTP::Commands::Get.(uri, connection: connection)
        entity = JSON.parse response.body

        counter = entity['counter']
      end
    end
  end
end
