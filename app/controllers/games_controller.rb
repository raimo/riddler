class GamesController < ApplicationController
  before_filter :load_highscores, :only => [ :new, :show ]

  def new
  end

  def create
    ActiveRecord::Base.transaction do
      current_user.update_facebook_data(@fb_session)
    end

    ActiveRecord::Base.transaction do
      @game = current_user.create_game
      redirect_to [@game, @game.questions.create]
    end
  end
  
  def show
    @game = current_user.games.find(params[:id])
  end
  
  private 

  def load_highscores
    @users = User.find_user_and_friends(current_user.id)
    @week_best_users = User.find_user_and_friends_ordered_by_week_score(current_user.id)
  end
end
