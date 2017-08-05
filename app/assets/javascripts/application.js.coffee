# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
# vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file. JavaScript code in this file should be added after the last require_* statement.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#= require jquery
#= require jquery-ui
#= require jquery-ui/i18n/datepicker-hu
#= require jquery_ujs
##= require rails-ujs
#= require jquery.initialize
#= require jquery.facebox
#= require jquery-ui-timepicker-addon/dist/jquery-ui-timepicker-addon
#= require_tree .

$('table#viewers a.kill, table#viewers a.block').on 'click', (e) ->
  e.preventDefault()

  jQuery.ajax
    url: $(this).attr('href')
    method: 'GET'
    success: (data, status, xhr) ->
      alert('Gyilok/Blokk kesz')
    error: (data, status, lofasz) ->
      alert('Tulelte!!!!')
