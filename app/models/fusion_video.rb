class FusionVideo < ApplicationRecord

  DOWNLOAD_BASE = 'http://dragonhall.hu:81'

  establish_connection :dragonhall
  self.table_name = :fusion_pdp_files

  pretty_columns :file_

  default_scope {where(:file_status => 0)}

  def title
    if !defined?(@title) or @title.blank?
      begin
        t1 = FusionVideo.arel_table
        t2 = Arel::Table.new :fusion_pdp_downloads

        result = FusionVideo.connection.exec_query(
            t2.project(t2[:dl_name])
                .join(t1).on(t1[:download_id].eq(t2[:download_id]))
                .where(t1[:file_id].eq(self.id)).to_sql)

      rescue
        result = nil
      end

      if result && result.count > 0
        @title = result.rows.first.first # FIXME Dirty
      else
        logger.debug "Fusion did not provided title for '#{File.basename(url)}', falling back to filename"
        @title = File.basename(url).sub(/\.[a-z]+$/, '').split('_').find_all do |e|
          !e.match(/(dumet|izzy|brolly|dh\+|dragonhall)/i)
        end.join(' ').sub(/\[.+?\]/, '').strip
      end
    end
    @title
  end

  def self.from_filepath(path)
    url = path.sub('/szeroka/dh0/load', DOWNLOAD_BASE)
    where(:file_url => url).first
  end

end