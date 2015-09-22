module HTTP
  module Server
    module RequestHandler
      attr_reader :path_params
      attr_reader :response

      def self.included(cls)
        cls.send :dependency, :logger, Telemetry::Logger
        cls.extend Call
      end

      module Call
        def call(*args)
          instance = build(*args)
          instance.call
        end
      end

      def connection
        @response.connection
      end

      def request
        @response.request
      end
    end
  end
end
