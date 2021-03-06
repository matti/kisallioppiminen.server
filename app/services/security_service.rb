class SecurityService

  # returns []
  # constants in /config/initializers/constants.rb
  # FAKE_COURSES_CHECK_MIN - number of courses needed for test
  # FAKE_COURSES_STUDENT_MIN - number of students in all courses needed to pass test
  def self.fake_courses?
    result = []
    suspects = fake_course_suspects
    suspects.each do |sid|
      i = {}
      user = UserService.user_by_id(sid)
      i["id"] = sid
      i["name"] = user.first_name + " " + user.last_name
      i["email"] = user.email
      i["students"] = count_students(sid)
      i["courses"] = CourseService.teacher_courses_with_student_count(sid)
      result << i
    end
    return result
  end
  
  # returns nothing
  # deletes all courses (+related data) by user (id: sid)
  def self.delete_all_courses(sid)
    ids = TeachingService.teacher_courses_ids(sid)
    ids.each do |i|
      CourseService.delete_course(i)
    end
  end
  
  # returns nothing
  # blocks user creating new courses
  def self.block_user(sid)
    u = UserService.user_by_id(sid)
    if u
      u.blocked = true
      u.save
    end
  end
  
  # returns nothing
  # blocks user creating new courses
  def self.unblock_user(sid)
    u = UserService.user_by_id(sid)
    if u
      u.blocked = false
      u.save
    end
  end
  
  # returns true if XSS safe
  # returns false if not XSS safe
  # BAD_CHARACTERS can be found in config/initializers/constans.rb
  def self.safe_string?(param)
    if BAD_CHARACTERS.any? { |c| param.include?(c) }
      return false
    else
      return true
    end
  end
  
  
  private
    def self.count_students(id)
      count = 0
      ids = TeachingService.teacher_courses_ids(id)
      ids.each do |i|
        count += CourseService.course_by_id(i).students.count
      end
      return count
    end
    
    def self.fake_course_suspects
      result = []
      ranking = TeachingService.course_count_rank
      ranking.each do |id, count|
        if count >= FAKE_COURSES_CHECK_MIN
          students = count_students(id)
          if students < FAKE_COURSES_STUDENT_MIN
            result << id
          end
        end
      end
      return result
    end
    
end
