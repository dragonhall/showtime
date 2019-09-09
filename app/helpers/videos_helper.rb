module VideosHelper
  def video_screenshot_tag(video)
    screenshot_path = "//#{video.screenshot_path}".sub(%r{^//}, '/')

    image_tag screenshot_path
  end
end
