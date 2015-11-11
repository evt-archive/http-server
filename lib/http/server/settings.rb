module HTTP
  module Server
    class Settings < ::Settings
      def self.data_source
        "settings/http_server.json"
      end

      def self.instance
        @instance ||= build
      end
    end
  end
end
