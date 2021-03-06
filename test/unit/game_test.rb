require 'test_helper'

class GameTest < ActiveSupport::TestCase
  
  def setup
    @game = Factory(:game)
    @user = @game.user
  end

  test "should have at least twice the number of choices than questions" do
    assert_not_nil @game.id
    assert @game.questions.size*2 <= @game.questions.map(&:choices).sum.size
  end

  test 'should not have rounds left when all wrong_answers are used' do
    (@game.max_wrong_answers - 1).times do
      @game.wrong_answers += 1
      assert @game.rounds_left?
    end
    
    @game.wrong_answers += 1
    assert !@game.rounds_left?
  end

  test 'should have next question coming when not all places are used' do
    (@game.round_count - @game.questions.count - 1).times do
      q = @game.questions.create
      q.answer!(q.choices.first.id)
    end
    assert @game.rounds_left?
  end

  test 'should calculate points correctly when several choices are selected' do
    @game_of_0_points = Factory(:game)
    @game_of_0_points.questions[0..2].each do |question|
      correct_choice = question.choices.first
      wrong_choice = question.choices.last
      wrong_choice.selected = true
      wrong_choice.save
      correct_choice.correct = true
      correct_choice.selected = true
      assert_not_equal wrong_choice, correct_choice
      correct_choice.save
    end
    assert_equal 0, @game_of_0_points.points
  end

  test 'should calculate points correctly when three correct choices are selected' do
    @game_of_3_points = Factory(:game)
    3.times do
      @game_of_3_points.questions.create()
    end
 
    @game_of_3_points.questions[0..2].each do |question|
      question.choices.detect do |choice|
        if choice.correct?
          choice.selected = true
          choice.save
        end
      end
    end
    assert_equal 3, @game_of_3_points.points
  end
end
