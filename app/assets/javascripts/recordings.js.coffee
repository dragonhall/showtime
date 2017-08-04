# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require lofJSlider
#= require jquery-ui
#= require jquery-ui/i18n/datepicker-hu
jQuery ->

  $('#recordings').lofJSidernews
    auto: false
    interval: 2000
    easing: 'easeOutBounce'
    duration: 1200
    maxItemDisplay: 4
    mainWidth: 720

  $('.recording-selector > .calendar').datepicker()
  $('select#series').selectmenu()

  $('#recordings .lof-main-item-desc a').on 'click', (e) ->
    e.preventDefault()
    video_url = $(this).attr('href')

    $.ajax
      url: '/player.html'
      method: 'GET'
      success: (data, status, jqXHR) ->
        player = $(data)
        player.find('source').attr('type', 'video/mp4')
        player.find('source').attr('src', video_url)

        console.log(player.find('source'))

        jQuery.facebox(player)






