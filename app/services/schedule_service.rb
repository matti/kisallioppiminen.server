class ScheduleService

  #
  def self.all_schedules
    return Schedule.all
  end
  
  #
  def self.name_reserved?(cid, name)
    return Schedule.where(course_id: cid, name: name).any?
  end
  
  #
  def self.add_new_schedule(cid, name)
    course = CourseService.course_by_id(cid)
    schedule = Schedule.new(course_id: cid, name: name)
    if course and not name_reserved?(cid, name) and schedule.save
      return true;
    else
      return false;
    end
  end
  
end
