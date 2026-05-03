# frozen_string_literal: true

class ExampleJob < ApplicationJob
  def perform
    (1..10).each do |i|
      at(i, 10, "Performing #{i} of 10")
      puts "Performing #{i} of 10"
      sleep(10)
    end
  end
end
