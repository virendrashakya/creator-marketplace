require "open3"
require "fileutils"
require "tmpdir"

class FrostedPreviewService
  CACHE_DIR = Rails.root.join("tmp", "cache", "frosted_previews")

  def self.call(attachment)
    new(attachment).process
  end

  def initialize(attachment)
    @attachment = attachment
  end

  def process
    return nil if @attachment.blank? || !@attachment.attached?

    FileUtils.mkdir_p(CACHE_DIR)
    cache_path = CACHE_DIR.join("#{@attachment.blob.key}.jpg")

    if File.exist?(cache_path) && File.size(cache_path).positive?
      return File.binread(cache_path)
    end

    generate_frosted(cache_path)
  end

  private

  def generate_frosted(cache_path)
    blob_bytes = @attachment.download
    return nil if blob_bytes.blank?

    Dir.mktmpdir("frosted_preview_") do |tmp_dir|
      src_file = File.join(tmp_dir, "source.tmp")
      dst_file = File.join(tmp_dir, "frosted.jpg")

      File.binwrite(src_file, blob_bytes)

      magick_bin = find_magick_bin
      if magick_bin
        cmd = [
          magick_bin, src_file,
          "-resize", "80x80^",
          "-resize", "480x480^",
          "-gravity", "center",
          "-crop", "480x480+0+0",
          "+repage",
          "-gaussian-blur", "0x16",
          "-quality", "85",
          dst_file
        ]
        _stdout, stderr, status = Open3.capture3(*cmd)
        if status.success? && File.exist?(dst_file) && File.size(dst_file).positive?
          processed_bytes = File.binread(dst_file)
          File.binwrite(cache_path, processed_bytes)
          return processed_bytes
        else
          Rails.logger.warn("ImageMagick frosted blur failed: #{stderr}")
        end
      end
    end

    nil
  rescue => e
    Rails.logger.error("FrostedPreviewService error: #{e.message}")
    nil
  end

  def find_magick_bin
    [ "/opt/homebrew/bin/magick", "/usr/local/bin/magick" ].find { |f| File.file?(f) && File.executable?(f) } ||
      [ "magick", "convert" ].find { |bin| system("command -v #{bin} > /dev/null 2>&1") }
  end
end
