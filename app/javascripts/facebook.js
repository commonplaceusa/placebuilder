function fbEnsureInit(callback) {
    if(!window.fbApiInit) {
        setTimeout(function() {fbEnsureInit(callback);}, 50);
    } else {
        if(callback) {
            callback();
        }
    }
}

function facebook_connect_post_registration() {
  // Pulls an avatar and access token
  FB.login(function(response) {
    if (response.authResponse) {
      FB.api("/me", function(response) {
        // Do something with the data
        console.log(response);
        var avatar_url = 'https://graph.facebook.com/' + response.username + '/picture';
        console.log("Downloading avatar from " + avatar_url);
        $.getImageData({
          url: avatar_url,
          success: function(image) {
            console.log(image);
          },
          error: function(xhr, text_status) {
            console.log(xhr);
            console.log("ERROR: " + text_status);
          }});
      });
    }
  }, { scope: 'read_friendlists,offline_access' });
}
