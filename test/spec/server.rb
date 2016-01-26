require_relative './spec_init'

context 'Server' do
  test 'Request and Response' do
    iterations = (ENV['ITERATIONS'] || '1').to_i

    HTTP::Server::Controls::ExampleServer.run do |port, scheduler|
      uri = URI::HTTP.build :host => 'localhost', :port => port, :path => '/countdown'
      connection = HTTP::Commands::Connect.(uri, scheduler: scheduler)

      while iterations.to_i > 0
        entity = { 'iterations' => iterations }
        json = JSON.pretty_generate entity

        response = HTTP::Commands::Post.(json, uri, connection: connection)
        fail unless response.status_code == 201

        response = HTTP::Commands::Get.(uri, connection: connection)
        entity = JSON.parse response.body

        iterations = entity['counter']
      end
    end
  end
end
