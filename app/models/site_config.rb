class SiteConfig < ActiveRecord::Base
  after_save :reset_cache

  def self.instance
    @instance ||= SiteConfig.first || SiteConfig.new
  end

  def self.mail_sysadmins
    %w(fer@heypal.com nico@heypal.com).join(', ')
  end

  def self.method_missing(name, *args)
    if self.running_migrations?
      return self.default_to_constant(name)
    end
    if self.instance.attributes.has_key?(name.to_s)
      val = self.instance.attributes[name.to_s] if self.instance
      if val.present?
        val
      else
        # Backward compatibility with config constants
       self.default_to_constant(name)
      end
    else
      super
    end
  end

  def self.running_migrations?
    @migrating ||= !self.table_exists?
  end

  def self.default_to_constant(name)
    name.to_s.upcase.constantize
  end

  protected

  def reset_cache
    @instance = nil
  end
end
