class WordsController < ApplicationController
  def game
    grid_size = rand(3..10)
    @grid = generate_grid(grid_size)
    @start_time = Time.now

  end

  def score
    attempt = params[:word]
    end_time = Time.now
    start_time = params[:start_time].to_datetime
    @hash_results = run_game(attempt, params[:grid], start_time, end_time)
  end


  private
  require 'open-uri'

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    words = ('A'..'Z').to_a
    number = 0
    words_grid = []
    while number < grid_size
      words_grid << words.sample
      number += 1
    end
    return words_grid
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    words = File.read('/usr/share/dict/words').upcase.split("\n")
    time = (end_time.to_f - start_time.to_f) / 1000

    attempt_split = attempt.upcase.chars
    attempt_split.each do |l|
      if grid.include? l
        grid.delete_at(grid.index(l))
      else
        return returns_hash(time, nil, 0, "not in the grid")
      end
    end

    if words.include? attempt.upcase
      score_user = 100 - time + attempt.length * 100
      return returns_hash(time, api_call(attempt)["outputs"][0]["output"], score_user, "well done")
    else
      return returns_hash(time, nil, 0, "not an english word")
    end
  end

  def returns_hash(time, translation, score, message)
    {
      time: time,
      translation: translation,
      score: score,
      message: message
    }
  end

  def api_call(attempt)
    key = "52fc809e-554e-4420-ad0b-99593b64f5fc"
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{key}&input=#{attempt}"
    attempt_serialized = open(url).read
    JSON.parse(attempt_serialized)
  end

end
