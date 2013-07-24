class CardholderImageUploader < ImageUploader
  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    asset_path("fallback/photo-placeholder.png")
    #"/images/fallback/" + [version_name, "default.png"].compact.join('_')
  end

  # process all files
  process :crop_square

  # Create different versions of your uploaded files:
  version :mobile_small do
    process resize_to_fit: [150, 150]
  end

  version :mobile_large do
    process resize_to_fit: [300, 300]
  end

  def crop_square
    manipulate! do |image|
      if image[:width] < image[:height]
        remove = ((image[:height] - image[:width])/2).round
        image.shave("0x#{remove}")
      elsif image[:width] > image[:height]
        remove = ((image[:width] - image[:height])/2).round
        image.shave("#{remove}x0")
      end
      image
    end
  end
end
