$(document).ready( function() {
  var $loginForm = $('.neon-form');

  $loginForm.find('.form-control').each(function(i, el)
  {
    var $this = $(el), $group = $this.closest('.input-group');

    $this.prev('.input-group-addon').click(function()
    { $this.focus(); });

    $this.on({
      focus: function()
      { $group.addClass('focused'); },

      blur: function()
      { $group.removeClass('focused'); }
    });
  });
});
