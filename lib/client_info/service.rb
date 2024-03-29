# frozen_string_literal: true

require 'net/https'

module ClientInfo
  class Service
    def initialize
      @config = HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config/client_info.yml').to_s))
      @config[:port] ||= @config[:scheme] == 'https' ? 443 : 80
      @config[:password] ||= Rails.application.secrets.control_api_password

      url_s = "#{@config[:scheme]}://#{@config[:hostname]}:#{@config[:port]}#{@config[:path]}"
      control_url_s = "#{@config[:scheme]}://#{@config[:hostname]}:#{@config[:port]}#{@config[:control_path]}"
      begin
        @url = URI.parse url_s
        @control_url = URI.parse control_url_s
      rescue URI::InvalidURIError => e
        Rails.logger.fatal "Unable to parse RTMP status/control URL: #{url_s}/#{control_url_s}"
        raise e
      end
    end

    # @return [Array<ClientInfo::Client>] Available clients
    def clients
      @clients = []

      req = Net::HTTP::Get.new(@url.path)
      req.basic_auth @config[:username], @config[:password]

      rsp = Net::HTTP.start(@url.hostname, @url.port) { |http| http.request req }
      xml = rsp.body
      doc = Nokogiri::XML(xml)

      client_nodes = doc.xpath('//server/application/live/stream/client')

      Rails.logger.debug "Client Node found: #{client_nodes.count}"

      @clients = client_nodes.map do |node|
        cid = node.css('id').text
        cid = '0' if cid.to_s.empty?

        address = node.css('address').text

        url = node.css('pageurl').text

        begin
          Client.new(
                      client_id: cid,
                      address: address,
                      url: url,
                      flash_ver: node.css('flashver').text,
                      country: $geoip.country(address).country_name,
                      flag: $geoip.country(address).country_code2.downcase,
                      city: $geocity.city(address).city_name,
                      user_id: parsed_query(url)['uid'].blank? ? -1 : parsed_query(url)['uid'].to_i
                    )
        rescue StandardError
          nil
        end
      end.compact
    end

    def kill_client(cid_or_address)
      params = {app: 'live'}

      if cid_or_address.match?(/^\d+\./)
        params[:addr] = cid_or_address
      else
        params[:clientid] = cid_or_address
      end

      qparams = params.map { |k, v| "#{k}=#{v}" }.join('&')
      #
      # req = Net::HTTP::Get.new(@control_url.path + '/drop/client?' + qparams)
      # req.basic_auth @config[:username], @config[:password]
      # # req.set_form_data params
      #
      #
      # rsp = Net::HTTP.start(@control_url.hostname, @control_url.port) do |http|
      #   http.request req
      # end

      system "curl -ks #{@control_url}/drop/client?#{qparams}"

      # Rails.logger.info "#{rsp.body} client(s) with #{cid_or_address} killed"
    end

    def block_client(address)
      # BlockedIp.create(address: address)
    end

    private

    def parsed_query(url)
      Rack::Utils.parse_query(URI.parse(url).query)
    end
  end
end
