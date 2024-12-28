# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.pretty_columns(prefix, options = {})
    skipped_columns = options[:except] || []       # add whatever column name you want here
    columns.each do |column|
      column_name = column.name
      next if skipped_columns.include? column_name

      unprefixed_col = column_name.scan(/^#{prefix}(.*)/).flatten.first

      define_method unprefixed_col.to_s do
        send column_name.to_s
      end

      define_method "#{unprefixed_col}=" do |value|
        send(column_name, value)
      end
    end
  end
end
