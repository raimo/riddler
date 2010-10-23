class GamesController < ApplicationController

  def new

    @game = get_current_game
    @game.round_count += 1;

    friends_statuses =
            fql(  "SELECT uid, status_id, message FROM status " +
                  "WHERE uid IN " +
                  "(SELECT uid2 FROM friend WHERE uid1 = #{@current_user.facebook_id.to_s})").
            sort_by {rand};

    status_to_guess = friends_statuses.pop()
    
    @correct_uid = status_to_guess['uid'];

    alternative_uids = get_two_unrelated_uids(friends_statuses, @correct_uid)
    alternative_uids = alternative_uids.concat([@correct_uid])

    @status_message = status_to_guess['message']

    @friends = fql( "SELECT uid, name, pic_square FROM user " +
                    "WHERE uid IN (#{alternative_uids.join(', ')})").
               sort_by {rand}

  end

  
  private

  def get_current_game
    game = session[:game]

     if (!game)
       game = Game.new
       game.save
     end
     if (!game.round_count)
         game.round_count = 0
     end

    game
  end

  def get_two_unrelated_uids(statuses, correct_uid)
    unrelated_uids = []
    cnt = 1;

    while unrelated_uids.size < 2
      uid = statuses.at(cnt)['uid']
      unrelated_uids.push(uid) if (uid != correct_uid)
      cnt += 1;
      break if (cnt > 999)
    end

    unrelated_uids
  end

end
