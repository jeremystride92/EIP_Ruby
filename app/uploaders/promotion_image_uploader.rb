class PromotionImageUploader < ImageUploader
  # Create different versions of your uploaded files:
  version :mobile_small do
    process resize_to_fit: [300, nil]
  end

  version :mobile_large do
    process resize_to_fit: [600, nil]
  end

  version :list_thumbnail do
    process resize_to_fit: [340, nil]
    process crop: '340x255+0+0'
  end

  version :display do
    process resize_to_fit: [600,nil]
  end

  private

  def crop(geometry)
    manipulate! do |img|
      img.crop(geometry)
      img
    end
  end
end
