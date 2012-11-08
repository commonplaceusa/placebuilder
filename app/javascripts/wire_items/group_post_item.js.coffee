CommonPlace.wire_item.GroupPostWireItem = CommonPlace.wire_item.WireItem.extend(
  template: "wire_items/post-item"
  tagName: "li"
  className: "wire-item"
  initialize: (options) ->
    self = this
    @model.on "destroy", ->
      self.remove()

    @in_reply_state = true

  afterRender: ->
    @model.on "change", @render, this
    @repliesView = {}
    @reply()
    @$(".post-body").truncate max_length: 450
    @checkThanked()
    @$(".ts-text").hide()  if @numThanks() is 0

  publishedAt: ->
    timeAgoInWords @model.get("published_at")

  avatarUrl: ->
    @model.get "avatar_url"

  title: ->
    @model.get "title"

  author: ->
    @model.get "author"

  first_name: ->
    @model.get "first_name"

  body: ->
    @model.get "body"

  numThanks: ->
    @directThanks().length

  peoplePerson: ->
    (if (@model.get("thanks").length is 1) then "person" else "people")

  events:
    "click div.group-post > .author > .person": "messageUser"
    "click .moreBody": "loadMore"
    "click .editlink": "editGroupPost"
    "click .thank-link": "thank"
    "click .share-link": "share"
    "click .reply-link": "reply"
    blur: "removeFocus"
    "click .ts-text": "showThanks"

  messageUser: (e) ->
    e and e.preventDefault()
    user = new User(links:
      self: @model.get("links").author
    )
    user.fetch success: ->
      formview = new MessageFormView(model: new Message(messagable: user))
      formview.render()

  isMore: ->
    not @allwords

  loadMore: (e) ->
    e.preventDefault()
    @allwords = true
    @render()

  canEdit: ->
    CommonPlace.account.canEditGroupPost @model

  editGroupPost: (e) ->
    e and e.preventDefault()
    formview = new PostFormView(
      model: @model
      template: "shared/group-post-edit-form"
    )
    formview.render()

  group: ->
    @model.get "group"

  groupUrl: ->
    @model.get "group_url"
)
