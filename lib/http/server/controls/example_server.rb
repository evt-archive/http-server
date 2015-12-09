module HTTP
  module Server
    module Controls
      class ExampleServer
        include HTTP::Server

        singleton_class.class_eval do
          attr_accessor :counter
        end

        get %r{^/countdown$} do |response, *|
          entity = { 'counter' => counter }
          json = JSON.pretty_generate entity

          response.deliver 200, json, 'application/json'

          # This allows tests to end naturally
          raise StopIteration if counter.zero?
        end

        post %r{^/countdown$} do |response, _, request|
          json = request.read_body
          entity = JSON.parse json
          counter = entity['counter']

          self.counter = counter - 1

          response.deliver 201

          __logger.pass "Returning #{self.counter.inspect}"
        end

        def self.run(port=nil, &block)
          port ||= 8000

          server = ExampleServer.new
          Telemetry::Logger.configure server
          server.bind_address = '127.0.0.1'
          server.port = port
          client = Client.build port, &block

          cooperation = ProcessHost::Cooperation.build

          cooperation.register server, 'server'
          cooperation.register client, 'client'

          cooperation.start
        end

        class Client
          attr_reader :block
          attr_writer :connection
          attr_reader :port
          attr_accessor :scheduler

          dependency :logger, Telemetry::Logger

          def initialize(port, block)
            @block = block
            @port = port
          end

          def self.build(port, &block)
            instance = new port, block
            Telemetry::Logger.configure instance
            instance
          end

          def start
            logger.trace "Starting (Port: #{port})"
            instance_exec connection, &block
            logger.debug "Finished (Port: #{port})"
          end

          def connection
            @connection = nil if @connection && @connection.closed?

            @connection ||=
              begin
                connection = Connection.client '127.0.0.1', port
                connection.scheduler = scheduler
                connection
              end
          end

          module ProcessHostIntegration
            def change_connection_scheduler(scheduler)
              self.scheduler = scheduler
            end
          end
        end
      end
    end
  end
end
