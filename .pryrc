# frozen_string_literal: true

if Rails.application.class.respond_to?(:parent)
  Pry.config.prompt_name = "#{Rails.application.class.parent.to_s.downcase}(#{Rails.env}) "
else
  Pry.config.prompt_name = "#{Rails.application.class.railtie_name.sub(/_application/, '')}(#{Rails.env}) "
end
