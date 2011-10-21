
db = null

player =
  co2emission: 0
  quest: null
  inventory: {}
  addItem: (item) ->
    unless @inventory[item.id]
      @inventory[item.id] = item
      @co2emission += item.co2
      true


initialize = () ->
  $.getJSON "/db.json", (data) ->
    db = data

  state = window.location.hash.substring(1)
  if state
    loadPlace state
  else
    loadPlace "/world/map"
  paintState()

loadPlace = (path) ->
  $screen = $('#screen')
  $.get path, (content) ->
    $screen.fadeOut ->
      $screen.html(content).fadeIn()
      window.location.hash = path

paintState = ->
  $('#stateTemplate').tmpl(
    player: player
  ).appendTo $('#state').empty()

print = (line) ->
  $('#printer').append("<p>#{line}</p>")


getItem = (item) ->
  #item = db.items[itemId]
  if player.addItem item
    print "You just acquired the #{item.label}"
  paintState()

travelTo = (dest) ->
  player.co2emission += dest.co2 if dest.co2
  paintState()
  loadPlace dest.path


elementToTrip = ($e) ->
  path: $e.attr('href')
  co2: $e.data('co2')
  price: $e.data('price')

elementToItem = ($e) ->
  id: $e.attr('href')[1..-1]
  co2: $e.data('co2')
  price: $e.data('price')
  weight: $e.data('weight')
  label: $e.html()


$ ->
  $('#device a.place').live 'click', -> travelTo elementToTrip $(this); false
  $('#device a.item').live 'click', -> getItem elementToItem $(this); false
  $('header > h1').click -> window.location.hash = ""; initialize()

  initialize()

