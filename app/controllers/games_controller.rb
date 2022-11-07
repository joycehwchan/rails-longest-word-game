require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    grid_size = rand(8..16)
    @grid = generate_grid(grid_size)
    @start_time = Time.now
    session[:score] = 0 if session[:score].nil?
  end

  def score
    @attempt = params[:guess].gsub(/\s+/, '')
    grid = params[:grid].split(' ')
    start_time = Time.parse(params[:start_time])
    @time = (Time.now - start_time).round(2)

    if valid_word?(@attempt) && word_in_grid?(@attempt, grid)
      @score = ((@attempt.length * 10) - @time).to_i
      session[:score] += @score
      @total_score = session[:score]
      @message = 'is a word from the grid!'
      @win = true
    else
      @score = 0
      @total_score = session[:score]
      @win = false
      return @message = 'is not an english word.' if valid_word?(@attempt) == false
      return @message = 'is not in the grid.' if word_in_grid?(@attempt, grid) == false
    end
  end

  def reset
    session[:score] = 0
    redirect_to root_path
  end

  private

  def generate_grid(grid_size)
    (1..grid_size).each.map { ('A'..'Z').to_a.sample }
  end

  def valid_word?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    serialized_dictionary = URI.open(url).read
    dictionary = JSON.parse(serialized_dictionary)
    dictionary['found'] == true
  end

  def word_in_grid?(attempt, grid)
    words = attempt.upcase.chars
    grid.each_with_index do |grid_v, grid_i|
      words.each_with_index do |word_v, word_i|
        next unless grid_v == word_v

        grid[grid_i] = nil
        words.delete_at(word_i)
      end
    end
    words.empty?
  end
end
