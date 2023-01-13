unless URI.respond_to?(:encode)
  require 'cgi'
  module URI
    def self.encode(string)
      ::CGI.escape(string)
    end
  end
end
