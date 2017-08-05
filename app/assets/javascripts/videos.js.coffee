jQuery ->
  jQuery.initialize 'form.simple_form:has(input#video_series)', ->
    $('input#video_series').autocomplete(
      source: JSON.parse($('input#video_series_values').val())
      appendTo: 'div.input.video_series'
    )
