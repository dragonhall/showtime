module ApplicationHelper
  def na_or_s(value)
    value.blank? ? 'N/A' : value
  end

  def na_or_s(check, &block)
    !!check ? yield : 'N/A'
  end


  def widget(widget, global: false, fullpath: false)
    path = global ? "widgets/#{widget}" : widget

    if fullpath
      render path
    else
      render partial: path
    end
  end
end
