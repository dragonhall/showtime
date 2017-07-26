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
  flowplayer.conf = { live: true };

  jQuery.initialize '.flowplayer', ->
    $('.flowplayer:has(video,script[type="application/json"])').flowplayer()
