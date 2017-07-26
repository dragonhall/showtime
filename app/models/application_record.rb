class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.pretty_columns(prefix, options = {})
    skipped_columns = options[:except] || []       #add whatever column name you want here
    columns.each do |column|
      column_name = column.name
      unless skipped_columns.include? column_name
        unprefixed_col = (column_name.scan /^#{prefix}(.*)/).flatten.first

        define_method "#{unprefixed_col}" do
          self.send "#{column_name}"
        end

        define_method "#{unprefixed_col}=" do |value|
          self.send(column_name, value)
        end
      end
    end
  end
end
