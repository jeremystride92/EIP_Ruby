object :@card_theme
attributes :name

node :portrait_background do |card_theme|
  card_theme.portrait_background.url
end

node :landscape_background do |card_theme|
  card_theme.landscape_background.url
end
