module HTTP
  module Server
    module Controls
      class ExampleServer
        include HTTP::Server

        singleton_class.class_eval do
          attr_accessor :iterations
        end

        get %r{^/countdown$} do |response, *|
          entity = { 'iterations' => iterations }
          json = JSON.pretty_generate entity

          response.deliver 200, json, 'application/json'

          # This allows tests to end naturally
          raise StopIteration if iterations.zero?
        end

        post %r{^/countdown$} do |response, _, request|
          json = request.read_body
          entity = JSON.parse json
          iterations = entity['iterations']

          self.iterations = iterations - 1

          response.deliver 201

          __logger.pass "Returning #{self.iterations.inspect}"
        end

        def self.run(port=nil, &block)
          port ||= 8000

          server = ExampleServer.new
          Telemetry::Logger.configure server
          server.bind_address = '127.0.0.1'
          server.port = port

          RunServer.(server, port: port, &block)
        end
      end
    end
  end
end
