module Fusion
  module API
    class << self


      def video_title(video: nil)
        begin
          t1 = Fusion::Video.arel_table
          t2 = Arel::Table.new :fusion_pdp_downloads

          result = connection.exec_query(
            t2.project(t2[:dl_name])
            .join(t1).on(t1[:download_id].eq(t2[:download_id]))
            .where(t1[:file_id].eq(video)).to_sql)

        rescue
          result = nil
        end

        if result && result.count > 0
          # return result.rows.first.first # FIXME Dirty
          row = result.rows.first
          row.size > 0 ? row.first : nil
        else
          return nil
        end
      end

      protected

      def connection
        # HACK Rails currently does not seem to support establishing connection without switching the current one
        @@connection ||= Fusion::User.class_eval { self.connection }
      end
    end
  end
end
