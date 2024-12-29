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
              elem.find('td:nth-child(3)').html(e.start_time)

            $('table#playlist_tracklist tbody').sortable('enable')
            $('table#playlist_tracklist tbody').css('color', '#222')
            $('table#playlist_tracklist tbody').css('cursor', 'crosshair')
            $('table#playlist_tracklist tbody').css('user-select', 'auto')

    $('table#playlist_tracklist tbody').css('cursor', 'crosshair')

    if $('.playlist_finalized input').is(':checked')
      console.log("Disable sorting")
      $(this).sortable('disable')
      $(this).css('cursor', 'default')
      $(this).css('user-select', 'none')
#  jQuery.initialize 'table#playlist_tracklist input[type="submit]'

  jQuery.initialize 'table#playlist_tracklist a.delete', ->
    $('table#playlist_tracklist > tbody > tr > td > a.delete').on 'click', (e) ->
      e.preventDefault()
      e.stopPropagation()
      # HACK: Presumably Rails JS integration triggers back the click event somehow...
      e.stopImmediatePropagation()
      # console.log("DEBUG: Delete icon pressed")

      track_table = $('table#playlist_tracklist tbody')

      track_table.sortable('disable')
      track_table.css('color', '#999')
      track_table.css('cursor', 'wait')
      track_table.css('user-select', 'none')

      track_row = $(this).parent().parent()
      track_id = track_row.attr('id')

      prompt = $(this).data('confirm')
      if(prompt != undefined)
        resp = window.confirm(prompt)
        console.log({response: resp})
        if(!resp)
          track_table.sortable('enable')
          track_table.css('color', '#222')
          track_table.css('cursor', 'crosshair')
          track_table.css('user-select', 'auto')
          return false
     
      jQuery.ajax
        url: $(this).attr('href')
        method: 'DELETE'
        dataType: 'JSON'
        async: false
        success: (data, status, jqXHR) ->
          track_row.remove()
     

      # Check if we removed the track on the success branch, if not, we skip the refresh phasae
      #if jQuery.contains(document, track_row[0])
      if track_table.find('tr#' + track_id).length > 0
        console.log("Skip refresh")
        track_table.sortable('enable')
        track_table.css('color', '#222')
        track_table.css('cursor', 'crosshair')
        track_table.css('user-select', 'auto')
        return false

      jQuery.ajax
        url: $('table#playlist_tracklist').parent().attr('action') + '/tracks'
        dataType: 'JSON'
        method: 'GET'
        success: (data, status, jqXHR) ->
          # In theory, at this point the deleted track is removed from the table, we only rewrite the position ids and start time
          # console.log("DEBUG: Track list refresh got data")
          # console.log(data)
          data.tracks.forEach (e) ->
            elem = $('table#playlist_tracklist').find('tr#' + e.id)
            elem.find('td:first-child').html(e.position)
            elem.find('td:nth-child(3)').html(e.start_time)

          track_table.sortable('enable')
          track_table.css('color', '#222')
          track_table.css('cursor', 'crosshair')
          track_table.css('user-select', 'auto')
        

  $('table#videos caption a.add').on 'click', (e) ->
    e.preventDefault()

    jQuery.facebox ajax: $(this).attr('href')

  $('table#videos tbody a.edit').on 'click', (e) ->
    e.preventDefault()

    jQuery.facebox ajax: $(this).attr('href')

# vim: ts=2 sw=2 et
