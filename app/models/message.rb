class Message < ActiveRecord::Base
  include IDEncoder
  
  belongs_to :user
  belongs_to :messagable, :polymorphic => true
  validates_presence_of :subject, :body, :user, :messagable

  has_many :replies, :as => :repliable
  
  def long_id
    IDEncoder.to_long_id(self.id)
  end
  
  def self.find_by_long_id(long_id)
    Message.find(IDEncoder.from_long_id(long_id))
  end

end
