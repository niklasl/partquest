var checkQuest, connect, db, elementToItem, elementToQuest, elementToTrip, getItem, loadPlace, message, paintPlayerState, player, setQuest, showQuestInfo, start, travelTo;
db = null;
player = {
  quest: null,
  travel: {
    current: null,
    prev: null
  },
  co2emission: 0,
  inventory: {},
  addItem: function(item) {
    if (!this.inventory[item.id]) {
      this.inventory[item.id] = item;
      this.co2emission += item.co2;
      return true;
    }
  }
};
connect = function() {
  $('header > *').click(function() {
    window.location.hash = "";
    return start();
  });
  $('#device a.path').live('click', function() {
    travelTo(elementToTrip($(this)));
    return false;
  });
  $('#device a.item').live('click', function() {
    getItem(elementToItem($(this)));
    return false;
  });
  return $('#quest a.info').live('click', function() {
    return showQuestInfo();
  });
};
start = function() {
  var path, state;
  $.getJSON("/db.json", function(data) {
    return db = data;
  });
  state = window.location.hash.substring(1);
  path = state ? state : "/world/intro";
  loadPlace({
    path: path
  });
  return paintPlayerState();
};
loadPlace = function(dest) {
  var $screen;
  $screen = $('#screen');
  return $.get(dest.path, function(content) {
    return $screen.fadeOut(function() {
      var prev;
      window.location.hash = dest.path;
      $screen.html(content).fadeIn();
      prev = player.travel.prev;
      if (prev && !$('a.path', $screen).length) {
        $screen.prepend("<a class='path' data-co2='" + player.travel.current.co2 + "' href='" + prev.path + "'>Travel back</a>");
      }
      return $('[typeof=Quest]', $screen).each(function() {
        return setQuest(elementToQuest($(this)));
      });
    });
  });
};
paintPlayerState = function() {
  return $('#stateTemplate').tmpl({
    player: player
  }).appendTo($('#state').empty());
};
message = function(line) {
  var $messages;
  $messages = $('#messages');
  $messages.append("<p>" + line + "</p>");
  console.log($messages.prop('scrollTop'));
  console.log($messages.prop('scrollHeight'));
  return $messages.animate({
    scrollTop: $messages.prop("scrollHeight")
  }, 30);
};
setQuest = function(quest) {
  return player.quest = quest;
};
getItem = function(item) {
  if (player.addItem(item)) {
    message("You just acquired the " + item.label);
  }
  checkQuest();
  return paintPlayerState();
};
checkQuest = function() {
  var amount, key, quest, _ref;
  quest = player.quest;
  _ref = quest.components;
  for (key in _ref) {
    amount = _ref[key];
    if (player.inventory[key] === void 0) {
      return;
    }
  }
  message("You have solved the quest and made " + quest.label + "!");
  player.inventory = {};
  return player.quest = null;
};
travelTo = function(dest) {
  var co2;
  player.travel.prev = player.travel.current;
  player.travel.current = dest;
  co2 = 0 + dest.co2;
  if (!isNaN(co2)) {
    player.co2emission += co2;
  }
  paintPlayerState();
  return loadPlace(dest);
};
showQuestInfo = function() {
  var key, quest, _results;
  quest = player.quest;
  message("The quest for " + quest.label + " requires:");
  _results = [];
  for (key in quest.components) {
    _results.push(message(key));
  }
  return _results;
};
elementToQuest = function($e) {
  var ref;
  ref = $e.attr('about').slice(1);
  return {
    id: ref,
    label: $('[property=label]', $e).html(),
    components: db.quests[ref].components
  };
};
elementToTrip = function($e) {
  return {
    path: $e.attr('href'),
    co2: $e.data('co2'),
    price: $e.data('price')
  };
};
elementToItem = function($e) {
  return {
    id: $e.attr('href').slice(1),
    co2: $e.data('co2'),
    price: $e.data('price'),
    weight: $e.data('weight'),
    label: $e.html()
  };
};
$(function() {
  connect();
  return start();
});