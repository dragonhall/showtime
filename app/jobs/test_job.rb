class TestJob < ApplicationJob

  def perform
    total = 100
    total.times do |i|

      at i+1, total, "Performing #{i + 1} of #{total}"
      sleep(0.5)
    end

    # completed
  end
end