module CardsHelper

  def card_status_toggle_button(card, classes:'', form_class:'change-card-status')
    label = card.active? ? 'Deactivate' : 'Activate'
    status_class = card.active? ? 'btn-warning' : 'btn-success'
    path = card.active? ? venue_card_deactivate_path(card) : venue_card_activate_path(card)

    button_to label, path, method: :put, class: [classes, status_class, 'btn'].join(' '), remote: true, form_class: form_class
  end

end
