CommonPlace.main.CreatePageView = CommonPlace.main.TourModalPage.extend(
  template: "main_page.tour.create_page"
  events:
    "click input.continue": "submit"
    "submit form": "submit"
    "click .next-button": "submit"

  initialize: (options) ->
    CommonPlace.main.TourModalPage.prototype.initialize options
    if @data && @data.isModel
      @model = @data
    else
      @createFeed
        name: CommonPlace.account.get("name") + "'s new page"

  afterRender: ->
    @hasAvatarFile = false
    @$('input[placeholder], textarea[placeholder]').placeholder()
    if @model
      @initAvatarUploader @$(".avatar_file_browse")
      kind = @model.get("kind")
      @$("[name=page_kind] [value=" + kind + "]").attr "selected", "selected"
    @$("select.dk").dropkick()
    unless @current
      @fadeIn @el
      @current = true

  createFeed: (feed_data) ->
    $.ajax
      type: "post"
      url: "/api" + CommonPlace.community.feeds.uri
      data: JSON.stringify(feed_data)
      dataType: "json"
      success: _.bind((feed) ->
        @model = new Feed(feed)
        @initAvatarUploader @$(".avatar_file_browse")
      , this)
      error: (attribs, response) ->
        $error = @$(".error")
        $error.html "Error creating feed"
        $error.show()

  submit: (e) ->
    self = this
    e.preventDefault()  if e
    @$(".error").hide()
    name = @$("input[name=name]").val()
    if name is ""
      @showError @$("input[name=name]"), @$(".error.name"), "Please enter a page name"
    else
      @model.save
        name: @$("input[name=name]").val()
        about: @$("textarea[name=about]").val()
        address: @$("input[name=address]").val()
        website: @$("input[name=website]").val()
        phone: @$("input[name=phone]").val()
        tags: @$("input[name=tags]").val()
        kind: @$("select[name=page_kind]").val()
        rss: @$("input[name=rss]").val()
      ,
        success: ->
          self.nextPage "subscribe", self.data

  initAvatarUploader: ($el) ->
    self = this
    @avatarUploader = new AjaxUpload($el,
      name: "avatar"
      action: "/api" + @avatarEditUrl()
      data: {}
      responseType: "json"
      autoSubmit: true
      onChange: (file, extension) ->
        self.toggleAvatar()
        $(".profile_pic").attr("src", file)

      onSubmit: (file, extension) ->

      onComplete: (file, response) ->
        self.model.set response
        self.$(".profile_pic").attr "src", self.avatarUrl()
    )

  toggleAvatar: ->
    @hasAvatarFile = true
    @$("a.avatar_file_browse").html "Photo Added! ✓"

  pageName: ->
    if @model
      @model.get "name"
    else
      ""

  about: ->
    if @model
      @model.get "about"
    else
      ""

  address: ->
    if @model
      @model.get "address"
    else
      ""

  rss: ->
    if @model
      @model.get "rss"
    else
      ""

  website: ->
    if @model
      @model.get "website"
    else
      ""

  phone: ->
    if @model
      @model.get "phone"
    else
      ""

  slug: ->
    if @model
      @model.get "slug"
    else
      ""

  deleteUrl: ->
    if @model
      @model.get "delete_url"
    else
      ""

  avatarUrl: ->
    if @model
      @model.link("avatar").thumb
    else
      "/avatars/missing.png"

  editUrl: ->
    if @model
      @model.link "edit"
    else
      ""

  avatarEditUrl: ->
    if @model
      @model.link "avatar_edit"
    else
      ""

)
