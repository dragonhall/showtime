# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require jquery
#= require jquery.tools.min
#= require jquery.facebox
#= require jquery.initialize
#= require flowplayer
#= require footages

jQuery ->
  flowplayer.conf = {live: true};

  jQuery.initialize '.viragjatekos', ->
    setTimeout((->
      jQuery.ajax
        url: '/tv/index.json'
        method: 'GET'
        success: (data, status, jqXHR) ->
          console.log(data)
          $('.playlist').slideUp(500)

          flowplayer('.viragjatekos', {clip: {sources: [type: 'video/flash', src: data.src]}, autoplay: true, live: true, swf: $('.viragjatekos').data('swf')})
          $('.viragjatekos').show()
    ), 3000)
