$.fn.fixedTableHeader = function () {
  var t = $(this);

  var tableOffset = t.offset().top;
  var fixed_table = $('<table></table>').css({
    'display': 'none',
    'position': 'fixed',
    'top': '0px',
    'background-color': 'white'
  });
  t.parent().append(fixed_table.append(t.find("thead").eq(0).clone()));

  fixed_table.find("th").each(function (i) {
    $(this).width(t.find("th").eq(i).width() + 1);
  });

  $(window).bind("scroll", function () {
    var offset = $(this).scrollTop();
    if (offset >= tableOffset && fixed_table.is(":hidden")) {
      fixed_table.show();
    }
    else if (offset < tableOffset) {
      fixed_table.hide();
    }
  });
  return t;
};