Array.prototype.clean = ->
  this.reduce ((buf, val) -> buf.concat(val) if typeof val != 'undefined'), new Array()


jQuery ->
  jQuery.initialize 'input.datepicker', ->
    $(this).datetimepicker(dateFormat: "yy-mm-dd", timeFormat: 'HH:mm')
  jQuery.initialize 'table#playlist_tracklist tbody', ->
    $(this).sortable

      update: (event, ui) ->
#        console.log $(this).sortable 'toArray'
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

#  jQuery.initialize 'table#playlist_tracklist input[type="submit]'


