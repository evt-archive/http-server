module HTTP
  module Server
    class Request
      attr_reader :raw_request
      attr_reader :connection

      dependency :logger, Telemetry::Logger

      def initialize(raw_request, connection)
        @raw_request = raw_request
        @connection = connection
      end

      def self.build(raw_request, connection)
        instance = new raw_request, connection
        Telemetry::Logger.configure instance
        instance
      end

      def [](field_name)
        raw_request[field_name]
      end

      def headers
        raw_request.headers
      end

      def path
        raw_request.path
      end

      def read_body
        content_length = self['Content-Length'].to_i
        connection.read content_length
      end

      def to_s
        raw_request.to_s
      end
    end
  end
end
