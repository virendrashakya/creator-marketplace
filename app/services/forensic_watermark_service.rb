require "open3"
require "fileutils"
require "tmpdir"

class ForensicWatermarkService
  CACHE_DIR = Rails.root.join("tmp", "cache", "forensic_watermarks")

  def self.call(attachment, viewer)
    new(attachment, viewer).process
  end

  def initialize(attachment, viewer)
    @attachment = attachment
    @viewer = viewer
  end

  def process
    return nil if @attachment.blank? || !@attachment.attached?
    return @attachment.download if @viewer.blank?

    # Non-images pass through without watermark
    return @attachment.download unless @attachment.content_type.to_s.start_with?("image/")

    FileUtils.mkdir_p(CACHE_DIR)
    cache_path = CACHE_DIR.join("#{@attachment.blob.key}_u#{@viewer.id}.jpg")

    if File.exist?(cache_path) && File.size(cache_path).positive?
      return File.binread(cache_path)
    end

    generate_watermarked(cache_path) || @attachment.download
  end

  private

  def generate_watermarked(cache_path)
    blob_bytes = @attachment.download
    return nil if blob_bytes.blank?

    Dir.mktmpdir("watermark_") do |tmp_dir|
      src_file = File.join(tmp_dir, "source.tmp")
      dst_file = File.join(tmp_dir, "watermarked.jpg")

      File.binwrite(src_file, blob_bytes)

      magick_bin = find_magick_bin
      if magick_bin
        stamp_text = "Licensed to @#{@viewer.handle} (Fan ##{@viewer.id}) • Wishful • #{Time.current.strftime('%Y-%m-%d')}"
        center_text = "@#{@viewer.handle} • ##{@viewer.id}"

        cmd = [
          magick_bin, src_file,
          "-gravity", "center",
          "-fill", "rgba(255,255,255,0.18)",
          "-pointsize", "24",
          "-annotate", "-30", center_text,
          "-gravity", "south",
          "-pointsize", "13",
          "-fill", "rgba(255,255,255,0.92)",
          "-undercolor", "rgba(10,12,16,0.72)",
          "-annotate", "+0+10", "  #{stamp_text}  ",
          "-set", "comment", stamp_text,
          "-quality", "90",
          dst_file
        ]

        _stdout, stderr, status = Open3.capture3(*cmd)
        if status.success? && File.exist?(dst_file) && File.size(dst_file).positive?
          processed_bytes = File.binread(dst_file)
          File.binwrite(cache_path, processed_bytes)
          return processed_bytes
        else
          Rails.logger.warn("ImageMagick forensic watermark failed: #{stderr}")
        end
      end
    end

    nil
  rescue => e
    Rails.logger.error("ForensicWatermarkService error: #{e.message}")
    nil
  end

  def find_magick_bin
    [ "/opt/homebrew/bin/magick", "/usr/local/bin/magick" ].find { |f| File.file?(f) && File.executable?(f) } ||
      [ "magick", "convert" ].find { |bin| system("command -v #{bin} > /dev/null 2>&1") }
  end
end
