if ENV['RAILS_ENV'] == 'test'
  begin
    require 'simplecov'
    SimpleCov.start
  rescue NameError
    # pass
  end
end