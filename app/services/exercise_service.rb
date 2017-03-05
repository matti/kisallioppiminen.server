class ExerciseService

  def self.add_exercises_to_course(exercises, cid)
    exercises.each do |key, value|
      Exercise.create(html_id: value, course_id: cid)
    end
  end

end