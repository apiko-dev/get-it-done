Template.Stripe.helpers({
  colors: function () {
    var boards = Boards.find();
    var colors = [];
    boards.forEach(function (board) {
      colors.push(board.config.bgColor || '#AAAAAA');
    });
    return colors;
  },

  lineWidth: function () {
    return 1 / Boards.find().count() * 100 + '%'; 
  }
});
