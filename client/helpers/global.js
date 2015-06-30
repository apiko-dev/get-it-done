COLORS = [
  '#4dc3ff',
  '#bc85e6',
  '#df7baa',
  '#f68d38',
  '#b27636',
  '#8ab734',
  '#14a88e',
  '#268bb5',
  '#6668b4',
  '#a4506c',
  '#67412c',
  '#3c6526',
  '#094558',
  '#bc2d07',
  '#999999'
]

Template.registerHelper('lightenDarkenColor', function(col, amt) {
  col = COLORS[col];
  var usePound = false;

  if (col[0] == "#") {
    col = col.slice(1);
    usePound = true;
    if (col.length === 3) col += col;
  }


  var num = parseInt(col, 16);

  var r = (num >> 16) + amt;

  if (r > 255) r = 255;
  else if (r < 0) r = 0;

  var b = ((num >> 8) & 0x00FF) + amt;

  if (b > 255) b = 255;
  else if (b < 0) b = 0;

  var g = (num & 0x0000FF) + amt;

  if (g > 255) g = 255;
  else if (g < 0) g = 0;

  return (usePound ? "#" : "") + (g | (b << 8) | (r << 16)).toString(16);
});

Template.registerHelper('colorByKey', function(key) {
  return COLORS[key];
});

Template.registerHelper('equals', function (a, b) {
  return a === b;
});

Template.registerHelper('isCurrentProject', function (board, togglProjectId) {
  return board.togglProject && board.togglProject.id == togglProjectId
});