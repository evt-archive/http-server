module HTTP
  module Server
    class Client
      attr_reader :connection
      attr_reader :handlers
      attr_reader :server

      dependency :logger, Telemetry::Logger

      def initialize(connection, handlers, server)
        @connection = connection
        @handlers = handlers
        @server = server
      end

      def self.build(*arguments)
        instance = new *arguments
        Telemetry::Logger.configure instance
        instance
      end

      def respond
        builder = ::HTTP::Protocol::Request::Builder.build
        logger.opt_trace "Server is reading request headers"
        builder << connection.gets until builder.finished_headers?
        logger.opt_debug "Server has read request headers"

        raw_request = builder.message
        request = Request.build raw_request, connection
        logger.opt_data request

        path = request.path

        response = Response.build connection, request.headers
        response["Connection"] = "close"

        http_method = raw_request.action

        handlers[http_method].each do |matcher, handler|
          match = matcher.match path
          next unless match

          path_params = match.to_a.tap &:shift
          handler.(response, path_params, request, server)
          return
        end

        RequestHandler::NotFound.(response)
      end
    end
  end
end
