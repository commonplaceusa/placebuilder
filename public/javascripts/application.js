
$.sammy("body")
  .get("close", function(c) {
    $.sammy("body").setLocation(currentIndex($.sammy("body")._location_proxy._last_location));
    $("#modal").html("");

  })
  .get("/", function(){})
  .get(/^\/?$/, function(c) {
    setTimeout(function(){
    $(window).trigger("resize.modal");
    }, 0);
  })
  .defaultCallback(function(c) {
    $.ajax({type: c.verb,
            url: c.path,
            data: c.verb == "get" ? null : c.params,
            dataType: "json",
            success: function(response) {
              if (response.redirect_to) {
                if (response.redirect_to.match(/^http/)) {
                  window.location = response.redirect_to;
                } else {
                  $.sammy("body").setLocation(response.redirect_to);
                  $.sammy("body").runRoute("get", response.redirect_to);
                }
              } else {
                merge(response);
              }
            }
           });
  })

  .setLocationProxy(new Sammy.CPLocationProxy($.sammy('body')));

$(document).ready(function() {
  $.sammy("body").run("/");
  $.preLoadImages("/images/loading.gif");
//  window.onscroll = setInfoBoxPosition;
  
  $('.inline-form input[type=file]').filestyle({
    image: "/images/upload.gif",
    imagewidth: 100,
    imageheight: 22
  });

  initInlineForm();

  $("#user_interest_list_input input:checkbox").each(function() {
    if ($(this).is(':checked')) {
      $("#interest_list_toggles td[data-value=" + $(this).val() + "]").addClass('checked');
      $(this).parent().show();
    }
  });
  $(".edit_interests #interest_list_toggles td").click(function() {
    var $checkbox = $("#user_interest_list_input input:checkbox[value=" + 
                     $(this).attr('data-value') + ']');
    if ($checkbox.is(':checked')) {
      $checkbox.removeAttr('checked');
      $(this).removeClass('checked');
    } else {
      $checkbox.attr('checked','checked');
      $(this).addClass('checked');
    }

    $checkbox.parent().toggle();
  });
    
  $('.disabled_link, a[href=disabled]').attr('title', "Coming soon!").tipsy({gravity: 'n'});
  $('header nav .disabled_link').attr('title', "Coming soon!").tipsy({gravity: 's'});
  showTooltips();
  
  renderMaps();
  
  $('#modules').sortable();
  $('#modules').disableSelection();
  
  $('ul#wire').accordion({'header': 'a.item_body', 
                          'active': false,
                          'collapsible': true, 
                          'autoHeight': false
                         });

  $('form').live('submit',function(e) {
    $('input[type=image]',$(this)).replaceWith('<img style="float: right"src="/images/loading.gif">');
  });
  
  $("#avatar_to_crop").load(function() {
    $(window).trigger('resize.modal');
    $('#avatar_to_crop').Jcrop({
      aspectRatio: 1,
      onChange: function(args) {
        $("#avatar_x").val(args.x);
        $("#avatar_y").val(args.y);
            $("#avatar_w").val(args.w);
        $("#avatar_h").val(args.h);
      }
    });
  });
  
  $(".tabs").tabs();

  $('input.date').datepicker({
    prevText: '&laquo;',
    nextText: '&raquo;',
    showOtherMonths: true,
    defaultDate: null
  });
  
  $('a[data-nohistory]').live('click', function(e) {
    e.preventDefault();
    $.sammy("body").runRoute("get",$(this).attr('href'));
  });
  
  $("#edit_avatar input").change(function() {
    $(this).parent("form").submit();
  });
  $(window).trigger("resize.modal");
  setTimeout(function(){$(window).trigger("resize.modal");}, 500);

  
});
  
function accordionReplies($replies) {
  if ($replies.get(0)) {
    $("#syndicate .replies").not($replies.get(0)).slideUp();
    $replies.slideDown();
  }
}
