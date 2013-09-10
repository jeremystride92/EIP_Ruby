class CardThemesController < InheritedResources::Base
  before_filter :find_venue
  before_filter :find_card_theme, except: [:index, :new, :create]

  def index
    authorize! :read, CardTheme

    @card_themes = @venue.card_themes
  end

  def show
    authorize! :read, @card_theme
  end

  def new
    authorize! :create, CardTheme
  end

  def create
    authorize! :create, @card_theme
  end

  def edit
    authorize! :update, @card_theme
  end

  def update
    authorize! :update, @card_theme
  end

  def delete
    authorize! :delete, @card_theme
  end

  private

  def find_card_theme
    @card_theme = CardTheme.find params[:id]
  end

  def find_venue
    @venue = current_user.venue
  end
end
