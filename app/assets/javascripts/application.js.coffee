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

$('table caption .viewers_refresh').on 'click', (e) ->
  e.preventDefault()

  jQuery.ajax
    url: $(this).attr('href')
    dataType: 'JSON'
    method: 'GET'
    success: (data, status, xhr) ->
      console.log(data)
      $('span#viewer_counter').html(data.length)
      $table = $('span#viewer_counter').parent().parent()

      # If we're the big table
      if $table.hasClass('span-23')

        $actions = $table.find('tbody tr:first-child td.actions').clone(true)
        $table.find('tbody').empty()

        console.log("Refilling viewers")

        jQuery.each data, (index, client) ->

          clnode = $("<tr id=\"client_#{client.client_id}\"><td class=\"userinfo\"></td><td></td><td></td><td></td><td></td><td></td></tr>")
          if client.user_id > 0
            clnode.find('.userinfo').html("<img src=\"#{client.avatar}\" width='16' height='16' /> <a href=\"http://dragonhall.hu/profile.php?lookup=#{client.user_id}\" target=\"_blank\">#{client.user_name}</a>")
          else
            clnode.find('.userinfo').html("<img src=\"#{client.avatar}\" /> #{client.user_name}")

          clnode.find('td:nth-child(2)').html(client.address)
          clnode.find('td:nth-child(3)').html(client.platform)
          clnode.find('td:nth-child(4)').html(client.flash_version)
          clnode.find('td:nth-child(5)').html("<img src=\"#{client.flag}\" /> #{client.country}")
          clnode.find('td:nth-child(6)').html(client.city)

          clnode.append($actions.clone())
          clnode.find('.kill').attr('href', "/viewers/#{client.client_id}/kill")
          clnode.find('.block').attr('href', "/viewers/#{client.address}/block")

          $table.find('tbody').append(clnode)

    error: (data, status) ->
      console.error('Error on refreshing viewers: ' + status)
