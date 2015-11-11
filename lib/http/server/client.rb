module HTTP
  module Server
    class Client
      attr_reader :connection
      attr_reader :handlers

      dependency :logger, Telemetry::Logger

      def initialize(connection, handlers)
        @connection = connection
        @handlers = handlers
      end

      def self.build(*arguments)
        instance = new *arguments
        Telemetry::Logger.configure instance
        instance
      end

      def respond
        builder = ::HTTP::Protocol::Request::Builder.build
        logger.trace "Server is reading request headers"
        builder << connection.gets until builder.finished_headers?
        logger.debug "Server has read request headers"

        request = builder.message
        logger.data request

        path = request.path
        logger.debug "Path: #{path}"

        response = Response.build connection, request.headers
        response["Connection"] = "close"

        handlers.each do |matcher, handler|
          match = matcher.match path
          next unless match

          path_params = match.to_a.tap &:shift
          handler.(response, path_params)
          return
        end

        RequestHandler::NotFound.(response)
      end
    end
  end
end
