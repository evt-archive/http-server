module HTTP
  module Server
    module RequestHandler
      class NotFound
        include RequestHandler

        def initialize(response)
          @response = response
        end

        def self.build(response)
          instance = new response
          Telemetry::Logger.configure instance
          instance
        end

        def self.finish(handler)
          response = handler.response
          self.(response)
          true
        end

        def call
          response.deliver 404
        end
      end
    end
  end
end
