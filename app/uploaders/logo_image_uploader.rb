class LogoImageUploader < ImageUploader
  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    asset_path("fallback/logo-placeholder.png")
    #"/images/fallback/" + [version_name, "default.png"].compact.join('_')
  end

  # Create different versions of your uploaded files:
  version :mobile_small do
    process resize_to_fit: [64, 64]
  end

  version :mobile_large do
    process resize_to_fit: [128, 128]
  end
end
