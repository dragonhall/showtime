Array.prototype.clean = ->
  this.reduce ((buf, val) -> buf.concat(val) if typeof val != 'undefined'), new Array()


jQuery ->
  jQuery.initialize 'input.datepicker', ->
    $(this).datetimepicker(dateFormat: "yy-mm-dd", timeFormat: 'HH:mm')
  jQuery.initialize 'table#playlist_tracklist tbody', ->
    $(this).sortable

      update: (event, ui) ->
#        console.log $(this).sortable 'toArray'
        $(this).sortable('disable')
        $(this).css('color', '#999')
        $(this).css('cursor', 'wait')
        $(this).css('user-select', 'none')
        new_order = jQuery.map $(this).sortable('toArray'), (e) ->
          e.replace('track_', '')
        delete new_order[new_order.indexOf('line-form')]
        delete new_order[new_order.indexOf('new-video')]

        new_order = jQuery.map new_order.clean(), (e) ->
          Number(e)

        console.log(new_order)

        jQuery.ajax
          url: $('table#playlist_tracklist').parent().attr('action') + '/tracks/reorder'
          dataType: 'JSON'
          data:
            tracks: new_order
          method: 'POST'
          success: (data, status, jqXHR) ->
#            console.log(data.tracks)

            data.tracks.forEach (e) ->
              elem = $('table#playlist_tracklist').find('tr#' + e.id)

#              console.log(elem)

              elem.find('td:first-child').html(e.position)
              elem.find('td:nth-child(4)').html(e.start_time)

            $('table#playlist_tracklist tbody').sortable('enable')
            $('table#playlist_tracklist tbody').css('color', '#222')
            $('table#playlist_tracklist tbody').css('cursor', 'crosshair')
            $('table#playlist_tracklist tbody').css('user-select', 'auto')

    $('table#playlist_tracklist tbody').css('cursor', 'crosshair')

    if $('.playlist_finalized input').is(':checked')
      console.log("Disable sorting")
      $(this).sortable('disable')
#  jQuery.initialize 'table#playlist_tracklist input[type="submit]'


  $('table#videos caption a.add').on 'click', (e) ->
    e.preventDefault()

    jQuery.facebox ajax: $(this).attr('href')

  $('table#videos tbody a.edit').on 'click', (e) ->
    e.preventDefault()

    jQuery.facebox ajax: $(this).attr('href')
