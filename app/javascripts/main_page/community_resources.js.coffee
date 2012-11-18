CommonPlace.main.CommunityResources = CommonPlace.View.extend(
  template: "main_page.community-resources"
  id: "community-resources"
  events:
    "submit .sticky form": "search"
    "keyup .sticky input": "debounceSearch"
    "click .sticky .cancel": "cancelSearch"

  initialize: ->
    _.bindAll(this, "debounceSearch")
    @eventAggregator.bind("searchBox:submit", @debounceSearch)

  afterRender: ->
    self = this
    @searchForm = new @SearchForm()
    @searchForm.render()
    $(@searchForm.el).prependTo @$(".sticky")

    @$("[placeholder]").placeholder()

  switchTab: (tab, single) ->
    self = this
    @view = @tabs[tab](this)
    @$(".search-switch").removeClass "active"
    if _.include(["users", "groups", "feeds"], tab)
      @$(".directory-search").addClass "active"
    else
      @$(".post-search").addClass "active"
    @view.singleWire single  if single
    if (self.currentQuery)
      self.search()
    else
      self.showTab()
      _kmq.push(['record', 'Wire Engagement', { 'Type': 'Tab', 'Tab': tab }]) if _kmq?

  winnowToCollection: (collection_name) ->
    self = this
    @view = @tabs[collection_name](this)
    @$(".search-switch").removeClass "active"
    @$(".post-search").addClass "active"  if _.include([], collection_name)
    (if (self.currentQuery) then self.search() else self.showTab())

  showTab: ->
    @$(".resources").empty()
    @$(".resources").append @loading()
    self = this
    @view.resources (wire) ->
      wire.render()
      $(wire.el).appendTo self.$(".resources")

  tabs:
    all_posts: (self) ->
      new DynamicLandingResources({})

    posts: (self) ->
      wire = new self.PostLikeWire(
        template: "main_page.post-resources"
        emptyMessage: "No posts here yet."
        collection: CommonPlace.community.posts
        isInAllWire: false
      )
      self.makeTab wire

    neighborhood: (self) ->
      wire = new self.PostLikeWire(
        template: "main_page.post-resources"
        emptyMessage: "No posts here yet."
        collection: CommonPlace.community.categories["neighborhood"]
      )
      self.makeTab wire

    help: (self) ->
      wire = new self.PostLikeWire(
        template: "main_page.post-resources"
        emptyMessage: "No posts here yet."
        collection: CommonPlace.community.categories["help"]
      )
      self.makeTab wire

    offers: (self) ->
      wire = new self.PostLikeWire(
        template: "main_page.post-resources"
        emptyMessage: "No posts here yet."
        collection: CommonPlace.community.categories["offers"]
      )
      self.makeTab wire

    publicity: (self) ->
      wire = new self.PostLikeWire(
        template: "main_page.post-resources"
        emptyMessage: "No posts here yet."
        collection: CommonPlace.community.categories["publicity"]
      )
      self.makeTab wire

    meetup: (self) ->
      wire = new self.PostLikeWire(
        template: "main_page.post-resources"
        emptyMessage: "No posts here yet."
        collection: CommonPlace.community.categories["meetups"]
      )
      self.makeTab wire

    other: (self) ->
      wire = new self.PostLikeWire(
        template: "main_page.post-resources"
        emptyMessage: "No posts here yet."
        collection: CommonPlace.community.categories["other"]
      )
      self.makeTab wire

    events: (self) ->
      wire = new self.PostLikeWire(
        template: "main_page.event-resources"
        emptyMessage: "No events here yet."
        collection: CommonPlace.community.events
      )
      self.makeTab wire

    announcements: (self) ->
      wire = new self.PostLikeWire(
        template: "main_page.announcement-resources"
        emptyMessage: "No announcements here yet."
        collection: CommonPlace.community.announcements
      )
      self.makeTab wire

    transactions: (self) ->
      wire = new self.PostLikeWire(
        template: "main_page.transaction-resources"
        emptyMessage: "No items here yet."
        collection: CommonPlace.community.transactions
      )
      self.makeTab wire

    group_posts: (self) ->
      wire = new self.PostLikeWire(
        template: "main_page.group-post-resources"
        emptyMessage: "No posts here yet."
        collection: CommonPlace.community.groupPosts
      )
      self.makeTab wire

    groups: (self) ->
      wire = new self.GroupLikeWire(
        template: "main_page.directory-resources"
        emptyMessage: "No groups here yet."
        collection: CommonPlace.community.groups
        active: "groups"
      )
      self.makeTab wire

    feeds: (self) ->
      wire = new self.GroupLikeWire(
        template: "main_page.directory-resources"
        emptyMessage: "No feeds here yet."
        collection: CommonPlace.community.feeds
        active: "feeds"
      )
      self.makeTab wire

    users: (self) ->
      wire = new self.GroupLikeWire(
        template: "main_page.directory-resources"
        emptyMessage: "No users here yet."
        collection: CommonPlace.community.users
        active: "users"
      )
      self.makeTab wire

  showPost: (post) ->
    self = this
    post.fetch success: ->
      self.showSingleItem post, Posts,
        template: "main_page.post-resources"
        fullWireLink: "#/posts"
        tab: "posts"

  showFeedPage: (feed_slug) ->
    $.getJSON("/api/feeds/" + feed_slug, _.bind((response) ->
      feed = new Feed(response)
      wire = new @PostLikeWire(
        template: "main_page.announcement-resources"
        emptyMessage: "No announcements here yet."
        collection: feed.announcements
      )
      @view = @makeTab wire
      @showTab()
    , @))

  showGroupPage: (group_id) ->
    $.getJSON("/api/groups/" + group_id, _.bind((response) ->
      group = new Group(response)
      wire = new @PostLikeWire(
        template: "main_page.announcement-resources"
        emptyMessage: "No announcements here yet."
        collection: group.posts
      )
      @view = @makeTab wire
      @showTab()
    , @))

  showAnnouncement: (announcement) ->
    self = this
    announcement.fetch success: ->
      self.showSingleItem announcement, Announcements,
        template: "main_page.announcement-resources"
        fullWireLink: "#/announcements"
        tab: "announcements"

  showEvent: (event) ->
    self = this
    event.fetch success: ->
      self.showSingleItem event, Events,
        template: "main_page.event-resources"
        fullWireLink: "#/events"
        tab: "events"

  showTransaction: (transaction) ->
    self = this
    transactions.fetch success: ->
      self.showSingleItem transaction, Transactions,
        template: "main_page.transaction-resources"
        fullWireLink: "#/transactions"
        tab: "transactions"

  showGroupPost: (post) ->
    self = this
    post.fetch success: ->
      self.showSingleItem post, GroupPosts,
        template: "main_page.group-post-resources"
        fullWireLink: "#/groupPosts"
        tab: "group_posts"

  highlightSingleUser: (user) ->
    @singleUser = user

  showSingleItem: (model, kind, options) ->
    @model = model
    @isSingle = true
    self = this
    wire = new LandingPreview(
      template: options.template
      collection: new kind([model],
        uri: model.link("self")
      )
      fullWireLink: options.fullWireLink
    )
    unless _.isEmpty(@singleUser)
      wire.searchUser @singleUser
      @singleUser = {}
    @switchTab options.tab, wire
    $(window).scrollTo 0

  showUserWire: (user) ->
    self = this
    user.fetch success: ->
      collection = new PostLikes([],
        uri: user.link("postlikes")
      )
      wire = new Wire(
        template: "main_page.user-wire-resources"
        collection: collection
        emptyMessage: "No posts here yet."
      )
      wire.searchUser user
      self.switchTab "posts", wire
      $(window).scrollTo 0


  debounceSearch: _.debounce(->
    @search()
  , CommonPlace.autoActionTimeout)
  search: (event) ->
    @currentQuery = @eventAggregator.query
    if @currentQuery
      @view.search @currentQuery
      @showTab()
    else
      @cancelSearch()

  cancelSearch: (e) ->
    @currentQuery = ""
    @$(".sticky form.search input").val ""
    @view.cancelSearch()
    @showTab()
    $(".sticky form.search input").removeClass "active"
    $(".sticky .cancel").hide()
    $(".resources").removeHighlight()

  makeTab: (wire) ->
    new @ResourceTab(wire: wire)

  loading: ->
    view = new @LoadingResource()
    view.render()
    view.el

  PostLikeWire: Wire.extend(_defaultPerPage: 15)
  GroupLikeWire: Wire.extend(_defaultPerPage: 50)
  ResourceTab: CommonPlace.View.extend(
    initialize: (options) ->
      @wire = options.wire

    resources: (callback) ->
      (if (@single) then callback(@single) else callback(@wire))

    search: (query) ->
      @single = null  if @single
      @wire.search query

    singleWire: (wire) ->
      @single = wire

    cancelSearch: ->
      @search ""
  )
  SearchForm: CommonPlace.View.extend(
    template: "main_page.community-search-form"
    tagName: "form"
    className: "search"
  )
  LoadingResource: CommonPlace.View.extend(
    template: "main_page.loading-resource"
    className: "loading-resource"
  )
)
