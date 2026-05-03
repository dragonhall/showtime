# frozen_string_literal: true

if defined?(Rails)
  Pry.config.prompt_name = if Rails.application.class.respond_to?(:parent)
                             "#{Rails.application.class.parent.to_s.downcase}(#{Rails.env}) "
                           else
                             "#{Rails.application.class.railtie_name.sub('_application', '')}(#{Rails.env}) "
                           end
end
