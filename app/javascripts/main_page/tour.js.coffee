CommonPlace.main.TourModal = CommonPlace.View.extend(
  id: "main"
  tagName: "div"
  overlayLevel: 1000
  changedElements: []

  events:
    "click .close": "end"
    "click #profile-box, #community-resources, #post-box": "end"

  initialize: (options) ->
    @firstSlide = true

  render: ->
    @$("#tour").html(@renderTemplate("main_page.tour.wire", this)).attr "class", "wire"
    $(@el).append("<div id='tour-shadow'></div>")
    $(@el).append(@renderTemplate("main_page.tour.modal", this))
    $("body").css(overflow: "hidden") #prevents the main page from scrolling during the tour
    $("#current-registration-page").css(overflow: "auto")

  first_name: ->
    CommonPlace.account.get "short_name"

  user_name: ->
    CommonPlace.account.get("name")

  avatar_url: ->
    CommonPlace.account.get("avatar_url")

  showError: ($el, $error, message) ->
    $el.addClass "input_error"
    $error.text message
    $error.show()

  showError: ($el, $error, message) ->
    $el.addClass "input_error"
    $error.text message
    $error.show()

  showPage: (page, data) ->
    self = this
    nextPage = (next, data) ->
      self.showPage next, data

    fadeIn = (el, callback) ->
      self.fadeIn el, callback

    @fadeOut()  unless @firstSlide
    view = {
      email: ->
        new CommonPlace.main.EmailView(
          nextPage: nextPage
          data: data
          fadeIn: fadeIn
          community: self.community
          account: self.account
        )

      address: ->
        new CommonPlace.main.AddressView(
          nextPage: nextPage
          data: data
          fadeIn: fadeIn
          community: self.community
          account: self.account
        )

      welcome: ->
        new CommonPlace.main.WelcomeView(
          nextPage: nextPage
          data: data
          fadeIn: fadeIn
          community: self.community
          account: self.account
        )

      profile: ->
        new CommonPlace.main.ProfileView(
          nextPage: nextPage
          data: data
          fadeIn: fadeIn
          community: self.community
          account: self.account
        )

      create_page: ->
        new CommonPlace.main.CreatePageView(
          nextPage: nextPage
          data: data
          fadeIn: fadeIn
          community: self.community
          account: self.account
        )

      subscribe: ->
        new CommonPlace.main.SubscribeView(
          nextPage: nextPage
          fadeIn: fadeIn
          community: self.community
          account: self.account
          data: data
          complete: self.options.complete
        )

      rules: ->
        new CommonPlace.main.RulesView(
          nextPage: nextPage
          fadeIn: fadeIn
          community: self.community
          account: self.account
          data: data
          complete: self.options.complete
        )

      neighbors: ->
        new CommonPlace.main.NeighborsView(
          complete: self.options.complete
          fadeIn: fadeIn
          community: self.community
          account: self.account
          data: data
          nextPage: nextPage
        )
    }[page]()
    _kmq.push(['record', 'Tour: ' + page + ' page'], {'community': self.community.get("name")}) if _kmq?
    view.render()

  welcome: ->
    @showPage "welcome"

  end: ->
    $("#tour-shadow").remove()
    $("#tour").remove()

  centerEl: ($el) ->
    $el.css @dimensions($el)
    w_height = $(window).height()
    el_height = $el.height()
    el_offset = $el.offset().top
    if (el_offset + el_height) > w_height
      $el.css(overflow: "auto")
      $el.height(w_height - el_offset)

  fadeOut: ->
    $current = @$("#current-tour-page")
    $current.css('filter', 'alpha(opacity=40)')
    $current.fadeOut "slow"
    , ->
      $current.empty()
      $current.hide()

  fadeIn: (el, callback) ->
    $next = @$("#next-tour-page")
    $current = @$("#current-tour-page")
    $tour = @$("#tour")
    $next.append el
    $next.css('filter', 'alpha(opacity=40)')
    @centerEl($next)
    $next.fadeIn "slow"
    , _.bind(->
      $current.html $next.children("div").detach()
      @centerEl($current)
      $current.show()
      $next.empty()
      $next.hide()
      callback()  if callback
    , this)

  dimensions: ($el) ->
    left = ($(window).width() - $el.width())/ 2
    left: left
)

CommonPlace.main.TourModalPage = CommonPlace.View.extend(
  initialize: (options) ->
    @data = options.data or isFacebook: false
    @fadeIn = options.fadeIn
    @nextPage = options.nextPage
    @complete = options.complete
    @template = @facebookTemplate  if options.data and options.data.isFacebook and @facebookTemplate

  validate_registration: (params, callback) ->
    validate_api = "/api" + CommonPlace.community.get("links").registration.validate
    $.getJSON validate_api, @data, _.bind((response) ->
      @$(".error").hide()
      valid = true
      unless _.isEmpty(response.facebook)
        window.location.pathname = CommonPlace.community.links.facebook_login
      else
        _.each params, _.bind((field) ->
          unless _.isEmpty(response[field])
            error = @$(".error." + field)
            input = @$("input[name=" + field + "]")
            errorText = _.reduce(response[field], (a, b) ->
              a + " and " + b
            )
            input.addClass "input_error"
            error.text errorText
            error.show()
            valid = false
        , this)
        callback()  if valid and callback
    , this)
)
