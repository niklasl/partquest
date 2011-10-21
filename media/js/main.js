var db, initialize, inventory, itemAction, linkToItem, loadPlace, paintState;
var __indexOf = Array.prototype.indexOf || function(item) {
  for (var i = 0, l = this.length; i < l; i++) {
    if (this[i] === item) return i;
  }
  return -1;
};
db = null;
inventory = [];
initialize = function() {
  return $.getJSON("/db.json", function(data) {
    db = data;
    $('#device a.place').live('click', function() {
      loadPlace($(this).attr('href'));
      return false;
    });
    return $('#device a.item').live('click', function() {
      linkToItem($(this));
      return false;
    });
  });
};
loadPlace = function(path) {
  var $screen;
  $screen = $('#screen');
  return $.get(path, function(content) {
    return $screen.fadeOut(function() {
      return $screen.html(content).fadeIn();
    });
  });
};
paintState = function() {
  return $('#inventoryTemplate').tmpl({
    inventory: inventory
  }).appendTo($('#inventory').empty());
};
linkToItem = function($el) {
  var cls, conditions, item, itemId;
  itemId = $el.attr('href').slice(1);
  item = db.items[itemId];
  conditions = ((function() {
    var _i, _len, _ref, _results;
    _ref = $el.attr('class').split();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      cls = _ref[_i];
      if (cls !== item) {
        _results.push(cls);
      }
    }
    return _results;
  })())[0];
  return itemAction(item, conditions);
};
itemAction = function(item, conditions) {
  if (__indexOf.call(inventory, item) < 0) {
    inventory.push(item);
  }
  return paintState();
};
$(function() {
  initialize();
  loadPlace("/world/map");
  return paintState();
});