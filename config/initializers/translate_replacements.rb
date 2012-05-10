# Override the translation method so that it always includes some default replacement variables

module ActionView::Helpers::TranslationHelper
  def translate_with_replacements(key, options={})
    options_with_replacements = options.merge({
      :site_name => SiteConfig.site_name,
      :site_url => SiteConfig.site_url,
      :support_email => SiteConfig.support_email
    })
    translate_without_replacements(key, options_with_replacements)
  end

  alias_method_chain :translate, :replacements
  alias :t :translate
end

module AbstractController
  module Translation
    def translate_with_replacements(key, options={})
      options_with_replacements = options.merge({
        :site_name => SiteConfig.site_name,
        :site_url => SiteConfig.site_url,
        :support_email => SiteConfig.support_email
      })
      translate_without_replacements(key, options_with_replacements)
    end

    alias_method_chain :translate, :replacements
    alias :t :translate
  end
end