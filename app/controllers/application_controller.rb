class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :require_oauth
  helper_method :points_stage

  def require_oauth
  	if session[:access_token].nil?
  		flash[:danger] = "You must connect to strava."
  		redirect_to root_path
  	end
  end 

  def sort_cyclists_by_elapsed_time(cyclists, stage)
    sorted_cyclists = []
    nil_cyclists = []

    cyclists.each_with_index do |cyclist, index|
      stage_effort = cyclist.stage_efforts.find_by(stage_id: stage)
      if stage_effort
        elapsed_time = stage_effort.elapsed_time # if stage_effort.elapsed_time
        if stage_effort.elapsed_time.to_i > 0
          sorted_cyclists << { 'cyclist' => cyclist, 'elapsed_time' => elapsed_time, 'point' =>5}
        else
          nil_cyclists << { 'cyclist' => cyclist, 'elapsed_time' => 0, 'point' => nil}
        end
      else
        nil_cyclists << { 'cyclist' => cyclist, 'elapsed_time' => nil, 'point' => nil}
      end
    end

    sorted_cyclists.sort_by!{|k| k['elapsed_time'].to_i}
    nil_cyclists.each {|item| sorted_cyclists << item}

    result = []
    sorted_cyclists.each { |item| result << item['cyclist']}    
    return result
  end

  def points_stage(place)
    points_array = [50, 30, 20, 18, 16, 14, 12, 10, 8, 7, 6, 5, 4, 3, 2, 1, -1]
    places_count = 16
    if place > places_count
      points_array[16]
    else
      points_array[place - 1]
    end
  end
end
