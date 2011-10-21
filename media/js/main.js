var db, elementToItem, elementToTrip, getItem, initialize, loadPlace, paintState, player, print, travelTo;
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
initialize = function() {
  var path, state;
  $.getJSON("/db.json", function(data) {
    return db = data;
  });
  state = window.location.hash.substring(1);
  path = state ? state : "/world/map";
  loadPlace({
    path: path
  });
  return paintState();
};
loadPlace = function(dest) {
  var $screen;
  $screen = $('#screen');
  return $.get(dest.path, function(content) {
    return $screen.fadeOut(function() {
      var prev;
      window.location.hash = dest.path;
      $screen.html(content).fadeIn();
      if ($('.map', $screen).length) {
        $screen.prepend("<a class='path' href='/world/map'>The World</a>");
      }
      prev = player.travel.prev;
      if (prev && !$('a.path', $screen).length) {
        return $screen.append("<a class='path' data-co2='" + prev.co2 + "' href='" + prev.path + "'>Back again</a>");
      }
    });
  });
};
paintState = function() {
  return $('#stateTemplate').tmpl({
    player: player
  }).appendTo($('#state').empty());
};
print = function(line) {
  return $('#printer').append("<p>" + line + "</p>");
};
getItem = function(item) {
  if (player.addItem(item)) {
    print("You just acquired the " + item.label);
  }
  return paintState();
};
travelTo = function(dest) {
  var co2;
  player.travel.prev = player.travel.current;
  player.travel.current = dest;
  co2 = 0 + dest.co2;
  if (!isNaN(co2)) {
    player.co2emission += co2;
  }
  paintState();
  return loadPlace(dest);
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
  $('#device a.path').live('click', function() {
    travelTo(elementToTrip($(this)));
    return false;
  });
  $('#device a.item').live('click', function() {
    getItem(elementToItem($(this)));
    return false;
  });
  $('header > *').click(function() {
    window.location.hash = "";
    return initialize();
  });
  return initialize();
});