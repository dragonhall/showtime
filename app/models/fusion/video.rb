class Fusion::Video < ApplicationRecord

  DOWNLOAD_BASE = 'http://dragonhall.hu:81'

  establish_connection :dragonhall
  self.table_name = :fusion_pdp_files

  pretty_columns :file_

  default_scope {where(:file_status => 0)}

  attr_accessor :title

  def title
    if @title.blank?
      _title = Fusion::API.video_title video: self.id
      @title = _title.blank? ? extract_title(File.basename(url)) : _title
    end
  end

  def self.from_filepath(path)
    url = path.sub('/szeroka/dh0/load', DOWNLOAD_BASE)
    where(:file_url => url).first
  end

  private

  def extract_title(file)
    file.sub(/\.[a-z]+$/, '').split('_').find_all do |e|
      !e.match?(/(dumet|izzy|brolly|dh\+|dragonhall)/i)
    end.join(' ').sub(/\[.+?\]/, '').strip
  end
end
