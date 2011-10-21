module GeneralHelper

  def delete_caches(caches)
    for cache in caches
      Rails.cache.delete(cache)
    end
  end

end