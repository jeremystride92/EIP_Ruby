class PromotionImageUploader < ImageUploader
  # Create different versions of your uploaded files:
  version :mobile_small do
    process resize_to_fit: [200, 200]
  end

  version :mobile_large do
    process resize_to_fit: [600, 300]
  end

  version :list_thumbnail do
    process resize_to_fit: [340,340]
  end

  version :display do
    process resize_to_fit: [800,400]
  end
end
