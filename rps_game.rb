class Score
  attr_accessor :total

  def initialize
    self.total = 0
  end

  def increase
    self.total += 1
  end

  def to_s
    total.to_s
  end
end

module History
  @history = []
  @game_count = 0

  def self.new_game
    @game_count += 1
    @history << { game_count: @game_count }
  end

  def self.add_choice(choice, player)
    @history.each do |game|
      if game[:game_count] == @game_count
        game[player.to_symbol] = choice.to_s
      end
    end
  end

  def self.data
    @history
  end

  def self.format_history
    log = ''
    @history.each do |game|
      game_count = game[:game_count]
      log += format(%(%02d:), game_count.to_s)
      log += " HUMAN:#{game[:human]}".ljust(18)
      log += "| " + "COMPUTER:#{game[:computer]}".ljust(18)
      log += "| " + "WINNER:#{game[:winner]}".ljust(18)
      log += "\n"
    end

    log
  end

  def self.winner=(player)
    @history.each do |game|
      game[:winner] = player if game[:game_count] == @game_count
    end
  end
end

module Move
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']

  def self.create(choice)
    case choice
    when 'rock' then @choice = Rock.new
    when 'scissors' then @choice = Scissors.new
    when 'paper' then @choice = Paper.new
    when 'lizard' then @choice = Lizard.new
    when 'spock' then @choice = Spock.new
    end

    @choice
  end
end

class Rock
  def to_s
    "rock"
  end

  def >(other_move)
    other_move.is_a?(Scissors) || other_move.is_a?(Lizard)
  end

  def <(other_move)
    other_move.is_a?(Paper) || other_move.is_a?(Spock)
  end
end

class Scissors
  def to_s
    "scissors"
  end

  def >(other_move)
    other_move.is_a?(Paper) || other_move.is_a?(Lizard)
  end

  def <(other_move)
    other_move.is_a?(Rock) || other_move.is_a?(Spock)
  end
end

class Paper
  def to_s
    "paper"
  end

  def >(other_move)
    other_move.is_a?(Rock) || other_move.is_a?(Spock)
  end

  def <(other_move)
    other_move.is_a?(Scissors) || other_move.is_a?(Lizard)
  end
end

class Lizard
  def to_s
    "lizard"
  end

  def >(other_move)
    other_move.is_a?(Paper) || other_move.is_a?(Spock)
  end

  def <(other_move)
    other_move.is_a?(Rock) || other_move.is_a?(Scissors)
  end
end

class Spock
  def to_s
    "spock"
  end

  def >(other_move)
    other_move.is_a?(Rock) || other_move.is_a?(Scissors)
  end

  def <(other_move)
    other_move.is_a?(Lizard) || other_move.is_a?(Paper)
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    self.score = Score.new
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What is your name?"
      n = gets.chomp
      break if !!(n =~ /[a-zA-Z]/)
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def to_symbol
    :human
  end

  def choose
    choice = nil

    loop do
      puts "Please choose rock, paper, scissors, lizard, or spock."
      choice = gets.chomp.downcase
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end

    self.move = Move.create(choice)
    History.add_choice(choice, self)
  end
end

module Personalities
  R2D2 = [
    { move: "rock", weight: 5, weight_distribution: 0 },
    { move: "paper", weight: 0, weight_distribution: 0 },
    { move: "scissors", weight: 0, weight_distribution: 0 },
    { move: "lizard", weight: 0, weight_distribution: 0 },
    { move: "spock", weight: 0, weight_distribution: 0 }
  ]
  HAL = [
    { move: "rock", weight: 1, weight_distribution: 0 },
    { move: "paper", weight: 1, weight_distribution: 0 },
    { move: "scissors", weight: 5, weight_distribution: 0 },
    { move: "lizard", weight: 1, weight_distribution: 0 },
    { move: "spock", weight: 1, weight_distribution: 0 }
  ]
  CHAPPIE = [
    { move: "rock", weight: 1, weight_distribution: 0 },
    { move: "paper", weight: 1, weight_distribution: 0 },
    { move: "scissors", weight: 1, weight_distribution: 0 },
    { move: "lizard", weight: 1, weight_distribution: 0 },
    { move: "spock", weight: 1, weight_distribution: 0 }
  ]
  SONNY = [
    { move: "rock", weight: 1, weight_distribution: 0 },
    { move: "paper", weight: 1, weight_distribution: 0 },
    { move: "scissors", weight: 1, weight_distribution: 0 },
    { move: "lizard", weight: 1, weight_distribution: 0 },
    { move: "spock", weight: 5, weight_distribution: 0 }
  ]
  NUMBER5 = [
    { move: "rock", weight: 1, weight_distribution: 0 },
    { move: "paper", weight: 1, weight_distribution: 0 },
    { move: "scissors", weight: 1, weight_distribution: 0 },
    { move: "lizard", weight: 5, weight_distribution: 0 },
    { move: "spock", weight: 1, weight_distribution: 0 }
  ]
  DEFAULT = [
    { move: "rock", weight: 1, weight_distribution: 0 },
    { move: "paper", weight: 1, weight_distribution: 0 },
    { move: "scissors", weight: 1, weight_distribution: 0 },
    { move: "lizard", weight: 1, weight_distribution: 0 },
    { move: "spock", weight: 1, weight_distribution: 0 }
  ]
  OPTIONS = [{ 'R2D2' => R2D2 }, { 'HAL' => HAL }, { 'Chappie' => CHAPPIE },
             { 'Sonny' => SONNY }, { 'Number 5' => NUMBER5 }]
end

class Computer < Player
  def set_name
    personality = Personalities::OPTIONS.sample
    self.name = personality.keys[0]
    @move_weights = personality.values[0]
  end

  def to_symbol
    :computer
  end

  def choose
    choice = ''
    calculate_weights
    target = rand

    @move_weights.reduce(0) do |limit, move_data|
      limit += move_data[:weight_distribution]

      # A display method for debugging:
      # display_choosing_process(move_data, target, limit)
      if target < limit
        break choice = move_data[:move]
      end

      limit
    end

    self.move = Move.create(choice)
    History.add_choice(choice, self)
  end

  def update_weight(choice, factor)
    index_to_update = @move_weights.index do |move_data|
      move_data[:move] == choice.to_s
    end

    @move_weights[index_to_update][:weight] *= factor
  end

  def calculate_weights
    sum_of_weights = @move_weights.reduce(0) do |sum, move_data|
      sum + move_data[:weight]
    end

    @move_weights.each do |move_data|
      weight = move_data[:weight].to_f

      move_data[:weight_distribution] = weight / sum_of_weights
    end
  end

  def display_move_weights
    puts
    puts "================ COMPUTER: MOVE WEIGHTS =================="

    @move_weights.each do |move_data|
      move_info = move_data[:move]
      weight_info = move_data[:weight]
      distribution_info = move_data[:weight_distribution]

      move = "MOVE: #{move_info}".ljust(15)
      move_weight = "WEIGHT: #{weight_info.round(2)}".ljust(14)
      weight_distribution = "DISTRIBUTION: #{distribution_info.round(3)}"
      puts "#{move}| #{move_weight}| #{weight_distribution}"
    end

    puts "---------------------------------------------------------"
  end

  private

  def display_choosing_process(move_data, target, limit)
    puts "TARGET: #{target}"
    puts "LIMIT FOR [ #{move_data[:move].upcase} ] : #{limit}"
  end
end

# Game Orchestration Engine
class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
    @human_name_format = ''
    @human_score_format = ''
    @computer_name_format = ''
    @computer_score_format = ''
    @score_to_win = nil
  end

  # Disable rubocop for #play method because it seems easier to understand the
  # method with each step in the game listed out. But having this many steps in
  # a single method causes Metrics complaints from rubocop.
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def play(score_to_win = 2)
    @score_to_win = score_to_win

    display_welcome_message

    loop do
      (system "clear") || (system "cls")
      History.new_game
      computer.calculate_weights
      computer.display_move_weights
      human.choose
      computer.choose
      display_moves
      calculate_score
      update_weights
      record_winner
      format_scoreboard_pieces
      display_scoreboard
      display_game_winner
      display_set_winner
      break unless play_again?
    end

    display_goodbye_message
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def display_welcome_message
    puts
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
  end

  def display_goodbye_message
    puts
    puts "Thanks for playing Rock, Paper, Scissors. Good Bye!"
    puts
  end

  def display_moves
    puts
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def calculate_score
    h_score = human.score
    h_move = human.move
    c_score = computer.score
    c_move = computer.move

    return h_score.increase if h_move > c_move
    return c_score.increase if h_move < c_move

    h_score.increase
    c_score.increase
  end

  def update_weights
    factor = 0.7
    h_move = human.move
    c_move = computer.move

    if h_move > c_move
      computer.update_weight(c_move, (1 - factor))
    elsif h_move < c_move
      computer.update_weight(c_move, (1 + factor))
    else
      computer.update_weight(c_move, (1 - factor))
    end
  end

  def record_winner
    h_move = human.move
    c_move = computer.move

    return History.winner = :human if h_move > c_move
    return History.winner = :computer if h_move < c_move
    History.winner = :tie
  end

  def format_scoreboard_pieces
    @human_name_format = human.name.center(13)
    @computer_name_format = computer.name.center(13)
    @human_score_format = human.score.to_s.center(13)
    @computer_score_format = computer.score.to_s.center(13)
  end

  def display_scoreboard
    puts
    puts "+---------- SCORE ----------+"
    puts "|#{@human_name_format}|#{@computer_name_format}|"
    puts "|#{@human_score_format}|#{@computer_score_format}|"
    puts "+---------------------------+"
  end

  def display_game_winner
    h = human
    c = computer

    puts

    if h.move > c.move
      puts "#{h.name} won the game!"
    elsif h.move < c.move
      puts "#{c.name} won the game!"
    else
      puts "The game is a tie!"
    end
  end

  def display_set_winner
    return unless set_winner?
    puts
    puts set_winner_message
    puts
    puts "Game/Set Over"
    puts
    puts "Press ENTER to display History and final Computer Move Weights"
    gets
    puts "======================= HISTORY ========================="
    puts History.format_history
    puts "---------------------------------------------------------"
    puts computer.display_move_weights
  end

  def set_winner?
    h_score = human.score.total
    c_score = computer.score.total

    h_score >= @score_to_win || c_score >= @score_to_win
  end

  def set_winner
    h_score = human.score.total
    c_score = computer.score.total

    if h_score == @score_to_win && c_score == @score_to_win
      "tie"
    elsif h_score == @score_to_win
      "human"
    else
      "computer"
    end
  end

  def set_winner_message
    winner = set_winner

    if winner == "tie"
      "!!!THE SET IS A TIE!!"
    elsif winner == "human"
      "!!!AND " + human.name.upcase + " WON THE SET!!!"
    else
      "!!!AND " + computer.name.upcase + " WON THE SET!!!"
    end
  end

  def play_again?
    return false if set_winner?
    answer = nil

    loop do
      puts
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n', 'yes', 'no'].include?(answer)
      puts "sorry, must be y or n."
    end

    answer.start_with?('y')
  end
end

RPSGame.new.play(10)
