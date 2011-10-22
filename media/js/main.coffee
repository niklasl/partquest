
db = null

player =
  quest: null
  travel:
    current: null
    prev: null
  co2emission: 0
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
  path = if state then state else "/world/map"
  loadPlace path: path
  paintState()

loadPlace = (dest) ->
  $screen = $('#screen')
  $.get dest.path, (content) ->
    $screen.fadeOut ->
      window.location.hash = dest.path
      $screen.html(content).fadeIn()
      if $('.map', $screen).length
        $screen.prepend("<a class='path' href='/world/map'>The World</a>")
      prev = player.travel.prev
      if prev and not $('a.path', $screen).length
        $screen.prepend(
          "<a class='path' data-co2='#{player.travel.current.co2}' href='#{prev.path}'>Travel back</a>")

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
  player.travel.prev = player.travel.current
  player.travel.current = dest
  co2 = 0 + dest.co2
  player.co2emission += co2 unless isNaN(co2)
  paintState()
  loadPlace dest


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
  $('#device a.path').live 'click', -> travelTo elementToTrip $(this); false
  $('#device a.item').live 'click', -> getItem elementToItem $(this); false
  $('header > *').click -> window.location.hash = ""; initialize()

  initialize()

