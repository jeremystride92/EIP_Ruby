ActiveAdmin.register Promotion do
  controller.skip_authorization_check
  controller do
    def permitted_params
      params.permit(promotion: [:title, :description, :image, :venue_id, :start_date, :end_date])
    end
  end
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
    column :start_date
    column :end_date
    column :created_at
    actions
  end

  index as: :grid do |promotion|
    render 'admin/promotion_grid_cell', promotion: promotion
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :image
      f.input :venue
      f.input :start_date
      f.input :end_date
    end
    f.actions
  end
end
