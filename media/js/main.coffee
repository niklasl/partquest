
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

connect = () ->
  $('header > *').click -> window.location.hash = ""; start()
  $('#device a.path').live 'click', -> travelTo elementToTrip $(@); false
  $('#device a.item').live 'click', -> getItem elementToItem $(@); false
  $('#quest a.info').live 'click', -> showQuestInfo()

start = () ->
  $.getJSON "/db.json", (data) ->
    db = data

  state = window.location.hash.substring(1)
  path = if state then state else "/world/intro"
  loadPlace path: path
  paintPlayerState()

loadPlace = (dest) ->
  $screen = $('#screen')
  $.get dest.path, (content) ->
    $screen.fadeOut ->
      window.location.hash = dest.path
      $screen.html(content).fadeIn()
      prev = player.travel.prev
      if prev and not $('a.path', $screen).length
        $screen.prepend(
          "<a class='path' data-co2='#{player.travel.current.co2}' href='#{prev.path}'>Travel back</a>")
      $('[typeof=Quest]', $screen).each ->
        setQuest elementToQuest $(@)

paintPlayerState = ->
  $('#stateTemplate').tmpl(
    player: player
  ).appendTo $('#state').empty()

message = (line) ->
  $messages = $('#messages')
  $messages.append("<p>#{line}</p>")
  console.log $messages.prop('scrollTop')
  console.log $messages.prop('scrollHeight')
  $messages.animate scrollTop: $messages.prop("scrollHeight"), 30


setQuest = (quest) ->
  player.quest = quest

getItem = (item) ->
  #item = db.items[itemId]
  if player.addItem item
    message "You just acquired the #{item.label}"
  checkQuest()
  paintPlayerState()

checkQuest = () ->
  quest = player.quest
  for key, amount of quest.components
    if player.inventory[key] is undefined
      return
  message "You have solved the quest and made #{quest.label}!"
  player.inventory = {}
  player.quest = null

travelTo = (dest) ->
  player.travel.prev = player.travel.current
  player.travel.current = dest
  co2 = 0 + dest.co2
  player.co2emission += co2 unless isNaN(co2)
  paintPlayerState()
  loadPlace dest

showQuestInfo = () ->
  quest = player.quest
  message "The quest for #{quest.label} requires:"
  for key of quest.components
    message key


elementToQuest = ($e) ->
  ref = $e.attr('about')[1..-1]
  id: ref
  label: $('[property=label]', $e).html()
  components: db.quests[ref].components

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
  connect()
  start()

