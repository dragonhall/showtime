jQuery ->
  $('#playlists_editables a.add').on 'click', (e) ->
    e.preventDefault()
    channel = $(this).parent().parent().parent().find('select#channel').val()
    url = document.location.protocol + "//" + document.location.host + "/channels/" + channel + "/playlists/new"
    jQuery.facebox {
      ajax: url
    }

  $('td.actions a.edit').on 'click', (e) ->
    e.preventDefault()
    jQuery.facebox ajax: $(this).attr('href')
    $(document).one 'beforeReveal.facebox', ->
      $('#facebox .content').width('600px');
    $(document).one 'close.facebox', ->
      $('#facebox .content').width('370px');

  $('#playlists_editables select#channel').on 'change', (e) ->
    channel = $(this).val()

    tbody = $(this).parent().find('tbody')

#    tbody.empty()

    $.ajax {
      url: '/channels/' + channel + '/playlists.json',
      dataType: 'json'
      success: (data, status, jqXHR) ->
        console.log { data: data, status: status }
    }

  $('table#channels td.actions a').on 'click', (e) ->
    e.preventDefault()

    jQuery.facebox(ajax: $(this).attr('href'))

  $('#playlists_editables a.play, table#channels caption a.add').on 'click', (e) ->
    e.preventDefault()

    jQuery.facebox
      ajax: $(this).attr('href')