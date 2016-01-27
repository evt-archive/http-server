module HTTP
  module Server
    REASON_PHRASES = {
      200 => 'OK',
      201 => 'Created',
      404 => 'Not Found'
    }

    def self.included(cls)
      cls.dependency :logger, Telemetry::Logger

      cls.extend AddHandler
      cls.extend Build
      cls.extend Handlers
      cls.extend HTTPMethods

      cls.setting :bind_address
      cls.setting :port

      cls.send :const_set, :ProcessHostIntegration, ProcessHostIntegration

      cls.send :attr_accessor, :ssl_context
      cls.send :attr_accessor, :stopped
    end

    module AddHandler
      def add_handler(http_method, matcher, handler)
        handlers[http_method][matcher] = handler
      end
    end

    module HTTPMethods
      def get(matcher, &handler)
        handlers['GET'.freeze][matcher] = handler
      end

      def post(matcher, &handler)
        handlers['POST'.freeze][matcher] = handler
      end
    end

    module Build
      def build(ssl_context=nil)
        instance = new
        instance.ssl_context = ssl_context
        Settings.instance.set instance
        Telemetry::Logger.configure instance
        instance
      end
    end

    module Handlers
      def handlers
        @handlers ||= Hash.new do |hash, http_method|
          hash[http_method] = {}
        end
      end
    end

    def start
      until stop?
        client_connection = server_connection.accept
        serve_client client_connection
      end
    end

    def serve_client(client_connection)
      handlers = self.class.handlers
      client = Client.build client_connection, handlers, self
      client.respond
    end

    def server_connection
      @server_connection ||= Connection::Server.build port, ssl_context: ssl_context
    end

    def stop
      self.stopped = true
    end

    def stop?
      stopped
    end

    module ProcessHostIntegration
      def change_connection_scheduler(scheduler)
        server_connection.scheduler = scheduler
      end
    end
  end
end
