# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require lofJSlider
#= require jquery-ui
jQuery ->

  $('#footages').lofJSidernews
    auto: false
    interval: 2000
    easing: 'easeOutBounce'
    duration: 1200

  $('.footage-selector > .calendar').datepicker()
  $('select#series').selectmenu()

  $('#footages .lof-main-item-desc a').on 'click', (e) ->
    e.preventDefault()

    jQuery.facebox ajax: "/player.html"



