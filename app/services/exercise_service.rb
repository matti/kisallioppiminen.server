class ExerciseService
  
  # returns Exercise or nil
  def self.exercise_by_id(eid)
    return Exercise.where(id: eid).first
  end
  
  # returns []
  def self.exercise_ids_of_course(cid)
    course = CourseService.course_by_id(cid)
    if not course
      return []
    end
    return course.exercises.ids
  end
  
  # returns Exercise or nil
  def self.exercise_by_course_id_and_html_id(cid, hid)
    course = CourseService.course_by_id(cid)
    if not course
      return nil
    end  
    return course.exercises.where(html_id: hid).first
  end
  
  # exercises: ["html_id1", "html_id2"]
  def self.exercises_by_course_id_and_html_id_array(cid, exercises)
    course = CourseService.course_by_id(cid)
    if not course or course.exerciselist == nil
      return []
    end
    return Exercise.where(exerciselist_id: course.exerciselist.id, html_id: exercises)
  end
  
  # returns ["html_id1", "html_id2"] or [] if no exercises
  def self.html_ids_of_exercises_by_course_id(cid)
    course = CourseService.course_by_id(cid)
    if not course or course.exerciselist == nil
      return []
    end
    return Exercise.where(exerciselist_id: course.exerciselist.id).map(&:html_id)
  end
  
  #
  def self.create_exercise(c_html_id, hid)
    elist = Exerciselist.where(html_id: c_html_id).first
    if not elist
      elist = Exerciselist.create(html_id: c_html_id)
    end
    Exercise.create(exerciselist_id: elist.id, html_id: hid)
  end
  
  #
  def self.all_exercises
    return Exercise.all
  end
  
  # returns true or false
  def self.exercise_on_course?(cid, hid)
    course = CourseService.course_by_id(cid)
    return (course and course.exercises.where(html_id: hid).any?)
  end
  
  # returns true or false
  def self.exercise_on_list?(list_html_id, e_html_id)
    list_id = ExerciselistService.elist_id_by_html_id(list_html_id)
    if not list_id
      return false
    end
    return Exercise.where(exerciselist_id: list_id, html_id: e_html_id).any?
  end
  
end
