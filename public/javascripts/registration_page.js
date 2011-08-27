$(function() {

  // all pages
  $('input[placeholder], textarea[placeholder]').placeholder();

  // Register
  $('#sign_in_button').click(function() {
    $(this).toggleClass("open");
    $(this).siblings("#sign_in_form").children("form").slideToggle();
  });

  // Add more info
  $("<div/>", { id: "file_input_fix" }).
    append($("<input/>", { type: "text", name: "file_fix", id: "file_style_fix" })).
    append($("<div/>", { id: "browse_button", text: "Browse..." })).
    appendTo("#user_avatar_input");
    
  
  $('#user_avatar').change(function() {
    $("#file_input_fix input").val($(this).val().replace(/^.*\\/,""));
  });
  
  $('#user_referral_source').change(function() {
    var selection = $("#user_referral_source option:selected").text();

    var new_label = {
      "At a table or booth at an event": "What was the event?",
      "In an email": "Who was the email from?",
      "On Facebook or Twitter": "From what person or organization?",
      "On another website": "What website?",
      "In the news": "From which news source?",
      "Word of mouth": "From what person or organization?",
      "Other": "Where?" }[selection];

    if (new_label) {
      $('#user_referral_metadata_input label').text(new_label);
      $('#user_referral_metadata_input').show('slow');
    }
  });

});