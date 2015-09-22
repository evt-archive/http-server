module HTTP
  module Server
    module Controls
      class ExampleServerConnection
        attr_reader :socket

        def initialize(socket)
          @socket = socket
        end

        def self.pair
          client, server = UNIXSocket.pair
          instance = new server
          return client, instance
        end

        def accept(&blk)
          blk.(socket)
        end
      end

      def self.get_json(handler_cls, *path_params, entities: {})
        entities ||= {}

        connection = StringIO.new

        request_headers = HTTP::Protocol::Request::Headers.build
        request_headers["Host"] = "localhost"
        request_headers["Accept"] = "application/json"

        response = HTTP::Server::Response.build connection, request_headers
        handler = handler_cls.new response, *path_params
        handler.store.merge entities unless entities.empty?
        handler.()

        connection.seek 0
        builder = HTTP::Protocol::Response::Builder.build
        builder << connection.gets until builder.finished_headers?

        response = builder.message

        Telemetry::Logger.get(self).data response
        content_length = response["Content-Length"].to_i

        if content_length > 0
          response_data = connection.read content_length
          Telemetry::Logger.get(self).data response_data

          resource = JSON.parse response_data
        else
          resource = nil
        end

        return response, resource
      end
    end
  end
end

