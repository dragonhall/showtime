# frozen_string_literal: true

class DatepickerInput < SimpleForm::Inputs::Base
  def input(_wrapper_options)
    Rails.logger.debug input_html_options
    @builder.text_field(attribute_name, input_html_options)
  end
end
