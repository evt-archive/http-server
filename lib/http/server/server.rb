module HTTP
  module Server
    UUID_MATCHER = %q{[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}$}

    REASON_PHRASES = {
      200 => "OK",
      404 => "Not Found",
    }

    def self.included(cls)
      cls.dependency :logger, Telemetry::Logger

      cls.extend AddHandler
      cls.extend Build
      cls.extend Handlers

      cls.setting :bind_address
      cls.setting :port

      cls.send :const_set, :ProcessHostIntegration, ProcessHostIntegration
    end

    module AddHandler
      def add_handler(matcher, &handler)
        handlers[matcher] = handler
      end
      alias_method :get, :add_handler
    end

    module Build
      def build
        instance = new
        Settings.instance.set instance
        Telemetry::Logger.configure instance
        instance
      end
    end

    module Handlers
      def handlers
        @handlers ||= {}
      end
    end

    def start
      running = true

      while running
        server_connection.accept do |client_connection|
          serve_client client_connection
        end
      end
    end

    def serve_client(client_connection)
      handlers = self.class.handlers
      client = Client.build client_connection, handlers
      client.respond
    end

    def server_connection
      @server_connection ||= Connection::Server.build bind_address, port
    end

    module ProcessHostIntegration
      def change_connection_policy(policy)
        server_connection.policy = policy
      end
    end
  end
end
