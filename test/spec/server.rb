require_relative './spec_init'

describe 'Server' do
  specify 'Request and Response' do
    counter = 1

    HTTP::Server::Controls::ExampleServer.run do
      while counter > 0
        entity = { 'counter' => counter }
        json = JSON.pretty_generate entity

        request = HTTP::Protocol::Request.new 'POST', '/countdown'
        request['Host'] = '127.0.0.1'
        request['Content-Type'] = 'application/json'
        request['Content-Length'] = json.bytesize 

        __logger.trace "Writing Request (Counter: #{counter}, Length: #{json.bytesize})"
        __logger.data json
        connection.write request
        connection.write json
        __logger.debug "Wrote Request (Counter: #{counter}, Length: #{json.bytesize})"

        response_builder = HTTP::Protocol::Response::Builder.build
        response_builder << connection.gets until response_builder.finished_headers?

        response = response_builder.message

        connection.close if response['Connection'] == 'close'


        request = HTTP::Protocol::Request.new 'GET', '/countdown'
        request['Host'] = '127.0.0.1'
        __logger.trace 'Writing Request'
        connection.write request
        __logger.debug 'Wrote Request'

        __logger.trace 'Reading Response'
        response_builder = HTTP::Protocol::Response::Builder.build
        response_builder << connection.gets until response_builder.finished_headers?
        __logger.debug 'Read Response'

        response = response_builder.message
        __logger.data response

        json = connection.read response['Content-Length'].to_i
        __logger.data json
        entity = JSON.parse json

        connection.close if response['Connection'] == 'close'

        counter = entity['counter']
      end
    end
  end
end
