
db = null

inventory = []

initialize = () ->
  $.getJSON "/db.json", (data) ->
    db = data
    $('#device a.place').live 'click', -> loadPlace $(this).attr('href'); false
    $('#device a.item').live 'click', -> linkToItem $(this); false

loadPlace = (path) ->
  $screen = $('#screen')
  $.get path, (content) ->
    $screen.fadeOut ->
      $screen.html(content).fadeIn()

paintState = ->
  $('#inventoryTemplate').tmpl(
    inventory: inventory
  ).appendTo $('#inventory').empty()

linkToItem = ($el) ->
  itemId = $el.attr('href')[1..-1]
  item = db.items[itemId]
  conditions = (cls for cls in $el.attr('class').split() when cls != item)[0]
  itemAction item, conditions

itemAction = (item, conditions) ->
  inventory.push item unless item in inventory
  paintState()

$ ->
  initialize()
  loadPlace "/world/map"
  paintState()

