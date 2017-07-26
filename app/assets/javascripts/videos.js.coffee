jQuery ->
  $('table#videos caption a.add').on 'click', (e) ->
    e.preventDefault()
    jQuery.facebox ajax: $(this).attr('href')

  $('table#videos tbody a.edit').on 'click', (e) ->
    e.preventDefault()
    jQuery.facebox ajax: $(this).attr('href')
