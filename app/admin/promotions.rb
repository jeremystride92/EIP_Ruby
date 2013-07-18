ActiveAdmin.register Promotion do
  controller.skip_authorization_check
  controller do
    def permitted_params
      # raise 'debug'
      params.permit(promotion: [:title, :description, :image, :venue_id, :start_date, :end_date, { card_level_ids: [] }])
    end
  end

  filter :venues
  filter :title
  filter :description
  filter :start_date
  filter :end_date
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :title
    column :image do |promotion|
      image_tag promotion.image.list_thumbnail, class: 'thumbnail-image'
    end
    column :description do |promotion|
      truncate promotion.description, length: 255, seperator: ' '
    end
    column :venue
    column :card_levels do |promotion|
      ul do
        promotion.card_levels.each do |card_level|
          li card_level.name
        end
      end
    end
    column :start_date
    column :end_date
    column :created_at
    actions
  end

  index as: :grid do |promotion|
    render 'admin/promotion_grid_cell', promotion: promotion
  end

  show do |promotion|
    attributes_table do
      row :venue
      row :photo do
        image_tag(promotion.image)
      end
      row :title
      row :description
      row :public_url do
        url = public_promotion_url(id: promotion, subdomain: promotion.venue.vanity_slug)
        link_to url, url
      end
      row :public_short_url do
        short_url = $short_url_cache.shorten(public_promotion_url(id: promotion, subdomain: promotion.venue.vanity_slug))
        link_to short_url, short_url
      end
      row "Visible to these card levels:" do |variable|
        div do
          span 'None', class: 'empty' if promotion.card_levels.empty?
          ul do
            promotion.card_levels.each do |card_level|
              li card_level.name
            end
          end
        end
      end
      row :start_date
      row :end_date
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :image
      f.input :venue
      f.input :card_levels, collection: promotion.venue.card_levels, as: :check_boxes
      f.input :start_date
      f.input :end_date
    end
    f.actions
  end
end
