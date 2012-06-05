Home.ui.Posting = Framework.View.extend
  template: "home.posting"
  klass: "discussion"

  render: (params) ->
    this.$el.html this.renderTemplate(params)

  remove: ->
    this.$(".form-container, .container").hide()

  show: (klass) ->
    this.klass = klass
    this.$(".general-help, .form-container, .links").hide()
    this.$("." + klass).show()
    this.$(".help." + klass + ".rounded_corners").hide()
    this.$(".links-" + klass).show()
    this.$(".links ." + klass).addClass "current"
    if klass is "share"
      this.$("#share_facebook").hide()

  showDefault: (klass) ->
    this.$(".go-back, .form-container").hide()
    this.$("." + klass).show()
    this.$(".links ." + klass).addClass "current"

  createPost: (e) ->
    e.preventDefault()
    title     = this.$("[name="+this.klass+"-title]").val()
    body      = this.$("[name="+this.klass+"-post]").val()
    price     = this.$("[name="+this.klass+"-price]").val()
    date      = this.$("[name="+this.klass+"-date]").val()
    starttime = this.$("[name="+this.klass+"-starttime]").val()
    endtime   = this.$("[name="+this.klass+"-endtime]").val()
    venue     = this.$("[name="+this.klass+"-venue]").val()
    address   = this.$("[name="+this.klass+"-address]").val()
    category  = this.$("[name=topics]").val()
    if category is "default"
      category = "Discussion"

    params = 
      "title"    : title
      "body"     : body
      "price"    : price
      "date"     : date
      "starttime": starttime
      "endtime"  : endtime
      "venue"    : venue
      "address"  : address
      "category" : category 
    this.sendPost(params)

  sendPost: (data) ->
    community = router.community 
    posts = new Backbone.Collection()
    posts.url = "/api" + community.get("links").posts
    posts.create data,
      success: (nextModel, resp) ->
        console.log("Sync triggered successfully. Next model is: #{nextModel} with a response of #{resp}")
      error: (attribs, response) ->
        console.log("Error syncing:#{response} with attributes:#{attribs}")
        
    posts.trigger("sync")
    router.navigate(community.get("slug") + "/home/share", {"trigger": true, "replace": true})
    this.remove()

  sharePost: (e) ->
    e.preventDefault()
    router.navigate(router.community.get("slug") + "/home", {"trigger": true, "replace": true})
    this.remove()

  showFacebook: (e) ->
    this.$("#share_facebook").toggle()

  events:
    "click .red-button": "createPost"
    "click .green-button": "sharePost"
    "click #facebookshare": "showFacebook" 
