Paperclip.interpolates :id_partition do |attachment, style|
  attachment.instance.id.to_s.scan(/.{4}/).join("/")
end

Paperclip.interpolates(:s3_alias_url) do |attachment, style|
  "#{attachment.s3_protocol(style)}://#{attachment.s3_host_alias}/#{attachment.path(style).gsub(%r{^/}, "")}"
end unless Paperclip::Interpolations.respond_to? :s3_alias_url
Paperclip.interpolates(:s3_path_url) do |attachment, style|
  "#{attachment.s3_protocol(style)}://#{attachment.s3_host_name}/#{attachment.bucket_name}/#{attachment.path(style).gsub(%r{^/}, "")}"
end unless Paperclip::Interpolations.respond_to? :s3_path_url
Paperclip.interpolates(:s3_domain_url) do |attachment, style|
  "#{attachment.s3_protocol(style)}://#{attachment.bucket_name}.#{attachment.s3_host_name}/#{attachment.path(style).gsub(%r{^/}, "")}"
end unless Paperclip::Interpolations.respond_to? :s3_domain_url
Paperclip.interpolates(:asset_host) do |attachment, style|
  "#{attachment.path(style).gsub(%r{^/}, "")}"
end unless Paperclip::Interpolations.respond_to? :asset_host

module Paperclip
  module Interpolations
    def place_id attachment, style_name
      attachment.instance.place_id
    end
  end
end
