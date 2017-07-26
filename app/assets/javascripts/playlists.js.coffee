jQuery ->
  jQuery.initialize 'table#playlist_tracklist a.add', ->
    $('table#playlist_tracklist a.add').on 'click', (e) ->
      e.preventDefault()
      tbody = $(this).parent().parent().parent().find('tbody')

      # form = $('<tr id="line-form"><td>&nbsp;</td><td class="autocomplete-target video">
      # <input type="text" placeholder="Videó címe" id="video_title" name="video_title" class="autocomplete" />
      # <input type="hidden" name="video_id" id="video_id" /></td><td></td><td></td>
      # <td class="actions"><a class="accept" href="#"><img src="/assets/icons/accept.png" /></a>
      # <a class="cancel"><img src="/assets/icons/cross.png" /></a></td></tr>')


      tbody.find('input#video_title').val('')
      tbody.find('input#video_id').val('')

      tbody.find('#line-form').show()

      $('input#video_title').autocomplete
#        source: '/videos/autocomplete'
        source: (request, response) ->
          jQuery.ajax
            url: '/videos/autocomplete'
            method: 'GET'
            data:
              term: request.term
              video_type: $('select#video_type').val()
            success: (data, status, jqXHR) ->
              response(data)
            error: (jqXHR, status, error) ->
              if jqXHR.status > 499
                alert(error)
              else
                return jqXHR.responseJSON

        appendTo: '.autocomplete-target.video'
        select: (event, ui) ->
          if ui.item
            $('input#video_title').val ui.item.label
            $('input#video_id').val ui.item.id

    # Re-triggering completion if user changed the filter after typing
    $('select#video_type').on 'change', (e) ->
      $('input#video_title').trigger('keydown') if $('input#video_title').val() != ''

    $('#line-form a.cancel').on 'click', (e) ->
      e.preventDefault()
      $('#line-form').hide()

    $('#line-form a.accept').on 'click', (e) ->
      e.preventDefault()

      jQuery.ajax
        url: $(this).attr('href')
        method: 'POST'
        dataType: 'JSON'
        data:
          track:
            video_id: $('input#video_id').val()
            playlist_id: $('input#playlist_id').val()
        success: (data, status, jqXHR) ->
          console.log([data, status])
          track = data.track

          delete_track_href = $('table#playlist_tracklist').parent().attr('action') + '/tracks/' + track.id

#          new_entry = $("
#            <tr id=\"track_#{track.id}\">
#              <td>#{track.position}</td>
#              <td>#{track.title}</td>
#              <td>#{track.length}</td>
#              <td>#{track.start_time}</td>
#              <td class=\"actions\">
#            </tr>
#          ")

          new_entry = $('tr#new-video').clone()

          new_entry.find('td').each (idx) ->
            if idx == 0
              $(this).html(track.position)
            else if idx == 1
              $(this).html(track.title)
            else if idx == 2
              $(this).html(track.length)
            else if idx == 3
              $(this).html(track.start_time)

          new_entry.find('td.actions a.delete').attr('href', new_entry.find('td.actions a.delete').attr('href') + '/' + track.id)
          new_entry.attr('id', 'track_' + track.id)

#          $('table#playlist_tracklist tbody').append new_entry
          new_entry.insertBefore $('tr#line-form')
          new_entry.show()

          $('#line-form').hide()

        error: (data, status, jqXHR) ->
          alert(data.message)


