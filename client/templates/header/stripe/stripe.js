Template.Stripe.helpers({
  colors: function () {
    var boards = Boards.find();
    var colors = [];
    boards.forEach(function (board) {
      colors.push(COLORS[board.config.bgColor] || '#AAAAAA');
    });

    if (colors.length === 0) return ['#f68d38'];

    return colors;
  },

  lineWidth: function () {

    var count = Boards.find().count() || 1;
    return 1 / count * 100 + '%'; 
  }
});
