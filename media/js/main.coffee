
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
  $('header > *').click -> window.location.hash = ""; start(); false
  $('#device a.path').live 'click', -> travelTo elementToTrip $(@); false
  $('#device a.item').live 'click', -> getItem elementToItem $(@); false
  $('#quest a.info').live 'click', -> showQuestInfo(); false

start = () ->
  $.getJSON "/db.json", (data) ->
    db = data

  state = window.location.hash.substring(1)
  path = if state then state else "/world/intro"
  loadScene path: path
  paintPlayerState()

loadScene = (dest, millis=300) ->
  $text = $('#text')
  $.get dest.path, (content) ->
    $text.animate scrollTop: 0, millis
    $text.fadeOut millis, ->
      window.location.hash = dest.path
      $text.html(content)
      $('[property=title]', $text).remove().appendTo($('#location').empty())
      $('[rel=depiction]', $text).remove().appendTo($('#screen').empty())
      $text.fadeIn millis
      prev = player.travel.prev
      if prev and not $('a.path', $text).length
        $text.append """
          <a class='path' data-co2='#{player.travel.current.co2}'
             href='#{prev.path}'>&larr; Travel back</a>"""
      $('[typeof=Quest]', $text).each ->
        setQuest elementToQuest $(@)

paintPlayerState = ->
  for box in ['quest', 'wallet']
    $("##{box}Template").tmpl(player: player).appendTo $("##{box}").empty()

message = (line) ->
  $messages = $('#messages')
  $messages.append("<p>#{line}</p>")
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
  message "You have solved the quest for the #{quest.label}!"
  loadScene path: quest.end, 3000
  player.inventory = {}
  #player.quest = null

travelTo = (dest) ->
  player.travel.prev = player.travel.current
  player.travel.current = dest
  co2 = 0 + dest.co2
  player.co2emission += co2 unless isNaN(co2)
  loadScene dest
  paintPlayerState()

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
  end: $('[rel=end]', $e).attr('href')

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

