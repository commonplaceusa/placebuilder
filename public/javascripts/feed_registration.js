$(function() {
  $("<div/>", { id: "file_input_fix" }).
    append($("<input/>", { type: "text", name: "file_fix", id: "file_style_fix" })).
    append($("<div/>", { id: "browse_button", text: "Browse..." })).
    appendTo("#feed_avatar_input");
  

  $('#feed_avatar').change(function() {
    $("#file_input_fix input").val($(this).val().replace(/^.*\\/,""));
  });


  // Avatar crop
  var updateCrop = function(coords) {
    $("#crop_x").val(coords.x);
    $("#crop_y").val(coords.y);
    $("#crop_w").val(coords.w);
    $("#crop_h").val(coords.h);
  };

  $("form.crop").load(function() {
    $("form.crop").css({ width: Math.max($("#cropbox").width(), 420) });
  });

  $("#cropbox").Jcrop({
    onChange: updateCrop,
    onSelect: updateCrop,
    aspectRatio: 1.0
  });
});