RablRails.configure do |config|
  # These are the default
  #config.cache_templates = true
  config.include_json_root = false
  #config.json_engine = :oj
  #config.xml_engine = 'LibXML'
  config.use_custom_responder = true
  #config.default_responder_template = 'show'
end
