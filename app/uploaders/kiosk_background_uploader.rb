class KioskBackgroundUploader < ImageUploader
  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    asset_path("mainfeat-bg.png")
  end
end
