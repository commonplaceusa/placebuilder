var LandingResources = CommonPlace.View.extend({ 
  template: "main_page/landing-resources",
  className: "resources",

  initialize: function(options) {
    this.account = options.account;
    this.community = options.community;
  },

  afterRender: function() {
    _(this.wires()).invoke("render");
  },

  wires: function() {
    if (!this._wires) { 
      this._wires = [
        (new PostWire({ collection: this.community.posts,
                        account: this.account,
                        el: this.$(".posts.wire"),
                        perPage: 3
                      })),
        
        (new EventWire({ collection: this.community.events,
                         account: this.account,
                         el: this.$(".events.wire"),
                         perPage: 3
                       })),
        
        
        
        
        (new AnnouncementWire({ collection: this.community.announcements,
                                account: this.account,
                                el: this.$(".announcements.wire"),
                                perPage: 3
                              })),
        
        (new GroupPostWire({ collection: this.community.groupPosts,
                             account: this.account,
                             el: this.$(".groupPosts.wire"),
                             perPage: 3
                           }))
      ];
    }
    return this._wires;
  }
  

});