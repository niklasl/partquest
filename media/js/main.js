var db, elementToItem, elementToTrip, getItem, initialize, loadPlace, paintState, player, print, travelTo;
db = null;
player = {
  co2emission: 0,
  quest: null,
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
  var state;
  $.getJSON("/db.json", function(data) {
    return db = data;
  });
  state = window.location.hash.substring(1);
  if (state) {
    loadPlace(state);
  } else {
    loadPlace("/world/map");
  }
  return paintState();
};
loadPlace = function(path) {
  var $screen;
  $screen = $('#screen');
  return $.get(path, function(content) {
    return $screen.fadeOut(function() {
      $screen.html(content).fadeIn();
      return window.location.hash = path;
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
  if (dest.co2) {
    player.co2emission += dest.co2;
  }
  paintState();
  return loadPlace(dest.path);
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
  $('#device a.place').live('click', function() {
    travelTo(elementToTrip($(this)));
    return false;
  });
  $('#device a.item').live('click', function() {
    getItem(elementToItem($(this)));
    return false;
  });
  $('header > h1').click(function() {
    window.location.hash = "";
    return initialize();
  });
  return initialize();
});