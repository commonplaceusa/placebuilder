CommonPlace.shared.HeaderView = CommonPlace.View.extend(
  template: "shared.header-view"
  id: "header"
  afterRender: ->
    nav = undefined
    if CommonPlace.account.isAuth()
      nav = new CommonPlace.shared.HeaderNav()
    else
      nav = new CommonPlace.shared.HeaderLogin()
    window.HeaderNavigation = nav
    nav.render()
    @$(".nav").replaceWith nav.el

  root_url: ->
    if CommonPlace.account.isAuth()
      "/" + CommonPlace.account.get("community_slug")
    else
      "/" + CommonPlace.community.get("slug")  if CommonPlace.community

  hasCommunity: ->
    CommonPlace.community

  community_name: ->
    if CommonPlace.account.isAuth()
      CommonPlace.account.get "community_name"
    else
      CommonPlace.community.get "name"  if CommonPlace.community
)