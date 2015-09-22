module HTTP
  module Server
    class Response
      attr_reader :connection
      attr_reader :request_headers
      attr_reader :response_headers

      dependency :logger

      def initialize(connection, request_headers, response_headers)
        @connection = connection
        @request_headers = request_headers
        @response_headers = response_headers
      end

      def self.build(connection, request_headers)
        response_headers = HTTP::Protocol::Response::Headers.build

        instance = new connection, request_headers, response_headers
        Telemetry::Logger.configure instance
        instance
      end

      def []=(header_name, value)
        response_headers[header_name] = value
      end

      def deliver(status_code, message_body = "", content_type = nil)
        logger.trace "Server is sending response"

        reason_phrase = REASON_PHRASES.fetch status_code
        response = HTTP::Protocol::Response.new status_code, reason_phrase
        response.merge_headers response_headers
        response["Content-Type"] = content_type if content_type

        if message_body.empty?
          logger.data response
          connection.write response
        else
          response["Content-Length"] = message_body.size
          logger.data response
          logger.data message_body
          connection.write response
          connection.write message_body
        end

        logger.debug "Server sent response"
      end
    end
  end
end
