PaperTrail.config.track_associations = false

module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    
    enum event: ::HashUtil.from_keys(%w[create update destroy]), _prefix: true
    
    def user
      User.where(id: self.whodunnit.to_i).first
    end
  end
end