require 'net/https'

module ClientInfo
  class Service
    def initialize
      @config = HashWithIndifferentAccess.new( YAML.load_file(Rails.root.join('config/client_info.yml').to_s))
      @config[:port] ||= @config[:scheme] == 'https' ? 443 : 80


      url_s = "#{@config[:scheme]}://#{@config[:hostname]}:#{@config[:port]}#{@config[:path]}"

      begin
        @url = URI.parse url_s
      rescue URI::InvalidURIError => e
        Rails.logger.fatal "Unable to parse RTMP status URL: #{url_s}"
        raise e
      end

    end
    # @return [Array<ClientInfo::Client>] Available clients
    def clients

      @clients = []

      req = Net::HTTP::Get.new(@url.path)
      req.basic_auth @config[:username], @config[:password]

      rsp =Net::HTTP.start(@url.hostname, @url.port) { |http| http.request req }
      xml = rsp.body
      doc = Nokogiri::XML(xml)

      client_nodes = doc.xpath('//server/application/live/stream/client')

      Rails.logger.debug "Client Node found: #{client_nodes.count}"

      @clients = client_nodes.map do |node|
        cid = node.css('id').text
        cid = cid.to_s.empty? ? '0' : cid
        Client.new(
            client_id: node.css('id').text,
            address: node.css('address').text,
            url: node.css('pageurl').text,
            flash_ver: node.css('flashver').text,
        ) rescue nil

      end.compact
    end
  end
end
