require "active_record"

module DestroySoon::ModelAdditions
  extend ActiveSupport::Concern
  included do
    scope :will_not_be_destroyed, -> { where(destroy_soon: false) }
  end

  def async_destroy
    unless self.destroy_soon
      self.update_attribute(:destroy_soon, true)

      DestroySoon::Queue.new.enqueue DestroySoon::Job.new(entity: self)
    end
  end
end
