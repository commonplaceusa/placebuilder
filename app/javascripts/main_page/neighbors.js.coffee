CommonPlace.main.Neighbors = CommonPlace.View.extend
  template: "main_page.sidebar.neighbors"

  afterRender: () ->
    CommonPlace.community.users.fetch
      success: (neighbors) =>
        neighbors.each (n) =>
          neighbor = n.toJSON()
          if neighbor.about isnt null
            neighbor.about.trim()
          html = this.renderTemplate("main_page.sidebar.neighbor", neighbor)
          this.$(".list").append html



