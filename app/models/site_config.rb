class SiteConfig < ActiveRecord::Base
  after_save :reset_cache

  def self.instance
    @instance ||= SiteConfig.first || SiteConfig.new
  end

  def self.method_missing(name, *args)
    if self.instance.attributes.has_key?(name.to_s)
      val = self.instance.attributes[name.to_s]
      if val.present?
        val
      else
        # Backward compatibility with config constants
        name.to_s.upcase.constantize
      end
    else
      super
    end
  end

  protected

  def reset_cache
    @instance = nil
  end
end
