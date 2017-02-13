class CheckmarksController < ApplicationController
  before_action :set_checkmark, only: [:destroy]

  protect_from_forgery unless: -> { request.format.json? }

  # GET /checkmarks
  def index
    @checkmarks = Checkmark.all
  end
  
  def cms
    if not user_signed_in?
      render :json => {"error" => "User must be signed in"}, status: 401
    end
  end
    
  # POST /checkmarks
  def mark
    @course = Course.find_by(coursekey: params[:coursekey])
    if not user_signed_in?
      render :json => {"error" => "User must be signed in"}, status: 401
    elsif @course.nil?
      render :json => {"error" => "Course not found"}, status: 403
    elsif Attendance.where(user_id: current_user.id, course_id: @course.id).empty?
      render :json => {"error" => "Et ole liittynyt kurssille"}, status: 422
    elsif @course.exercises.where(html_id: params[:html_id]).empty?
      render :json => {"error" => "Exercise not found"}, status: 403
    else
      html_id = params[:html_id]
      @exercise = Exercise.find_by(course_id: @course.id, html_id: html_id)
      @checkmark = Checkmark.find_by(exercise_id: @exercise.id, user_id: current_user.id)
      if @checkmark.nil?
        @checkmark = Checkmark.new(user_id: current_user.id, exercise_id: @exercise.id)
      end
      @checkmark.status = params[:status]
      if @checkmark.save 
        render :json => {"message" => "Checkmark saved"}, status: 201  
      else
        render :json => {"error" => "Checkmark not saved"}, status: 422
      end
    end
  end
  
  # opiskelijan yhden kurssin checkmarkit
  def student_checkmarks
    sid = params[:sid]
    cid = params[:cid]
    if not user_signed_in?
      render :json => {"error" => "User must be signed in"}, status: 401
    elsif sid.to_i != current_user.id and Teaching.where(user_id: current_user.id, course_id: cid).empty?
      render :json => {"error" => "Unauthorized"}, status: 401
    elsif Attendance.where(user_id: sid, course_id: cid).empty?
      render :json => {"error" => "User not on course"}, status: 422
    else
      @exercises = Exercise.where(course_id: cid).ids
      @cmarks = Checkmark.joins(:exercise).where(user_id: sid, exercise_id: @exercises).select("exercises.html_id","status")
      checkmarks = {}
      @cmarks.each do |c|
        checkmarks[c.html_id] = c.status
      end  
      render :json => checkmarks, status: 200
    end
        
  end
  
  # DELETE /checkmarks/1
  # DELETE /checkmarks/1.json
  def destroy
    @checkmark.destroy
    respond_to do |format|
      format.html { redirect_to checkmarks_url, notice: 'Checkmark was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checkmark
      @checkmark = Checkmark.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def checkmark_params
      params.permit(:user_id, :html_id, :coursekey, :status)
    end
end
