var GroupPostWireItem = WireItem.extend({
  template: "wire_items/post-item",
  tagName: "li",
  className: "wire-item",

  initialize: function(options) {
    this.account = options.account;
    this.shortbody = this.model.get("body").match(/\b([\w]+[\W]+){60}/);
    this.allwords = (this.shortbody == null);
  },

  afterRender: function() {
    var repliesView = new RepliesView({ collection: this.model.replies(),
                                        el: this.$(".replies"),
                                        account: this.account
                                      });
    repliesView.render();
    this.model.bind("change", this.render, this);
    var self = this;
    repliesView.collection.bind("add", function() { self.render(); });
  },

  replyCount: function() {
    var num = this.model.replies().length;
    return (num == 1 ? "1 reply" : num + " replies");
  },

  publishedAt: function() {
    return timeAgoInWords(this.model.get("published_at"));
  },

  avatarUrl: function() {
    return this.model.get("avatar_url");
  },

  title: function() {
    return this.model.get("title");
  },

  author: function() {
    return this.model.get("author");
  },

  body: function() {
    if (!this.allwords) {
      return this.shortbody[0];
    } else {
      return this.model.get("body");
    }
  },

  events: {
    "click .author": "messageUser",
    "click .moreBody": "loadMore",
    "mouseenter": "showInfoBox"
  },

  messageUser: function(e) {
    e && e.preventDefault();
    var user = new User({
      links: {
        self: this.model.get("links").author
      }
    });
    user.fetch({
      success: function() {
        var formview = new MessageFormView({
          model: new Message({messagable: user})
        });
        formview.render();
      }
    });
  },

  isMore: function() {
    return !this.allwords;
  },

  loadMore: function(e) {
    e.preventDefault();
    this.allwords = true;
    this.render();
  },
  
  getInfoBox: function(callback) {
    var account = this.account;
    this.model.group(function(group) {
      callback(new GroupInfoBox({ model: group, account: account }));
    });
  }

});