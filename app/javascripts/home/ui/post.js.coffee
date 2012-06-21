Home.ui.Post = Home.ui.WireItem.extend
  template: "home.post"

  className: "wire"

  events:
    "click .reply": "showReply"
    "click .thank": "thank"
    "click .help": "publicize"
    "click .post-reply-button": "reply"

  initialize: ->
    _.bindAll(this)
    @reply_text = "post-reply"
    @reply_button = "post-reply-button"

  render: ->
    presenter = new Home.presenter.Post(this.model)
    this.$el.html this.renderTemplate(presenter.toJSON())

    @reply_text = this.$("."+@reply_text)
    @reply_button = this.$("."+@reply_button)
    this.checkThanked()
    this.hideReplyButton()
    @reply_text.focus(this.showReplyButton)
    @reply_text.blur(this.hideReplyButton)

  showReply: (e) ->
    #this.$(".post-reply").focus()
    @reply_text.focus()

  showReplyButton: (e) ->
    #reply_button = this.$(".post-reply-button")
    @reply_button.show()
    
  hideReplyButton: (e) ->
    #if this.$(".post-reply").val().length is 0
      #this.$(".post-reply-button").hide()
    if @reply_text.val().length is 0
      @reply_button.hide()
    
