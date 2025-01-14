class Instructor < User
  # has_many :questionnaires
  has_many :questionnaires, dependent: :nullify

  QUESTIONNAIRE = [['My questionnaires', 'list_mine'],
                   ['All public questionnaires', 'list_all']].freeze

  SIGNUPSHEET = [['My signups', 'list_mine'],
                 ['All public signups', 'list_all']].freeze

  ASSIGNMENT = [['My assignments', 'list_mine'],
                ['All public assignments', 'list_all']].freeze

  def list_all(object_type, user_id)
    object_type.where("instructor_id = ? OR private = 0", user_id)
  end

  def list_mine(object_type, user_id)
    object_type.where("instructor_id = ?", user_id)
  end

  def get(object_type, id, user_id)
    # object_type.where("id = ? AND (instructor_id = ? OR private = 0)", id, user_id).first
    object_type.find_by("id = ? AND (instructor_id = ? OR private = 0)", id, user_id)
  end

  def my_tas
    courses = Course.where(instructor_id: self.id)
    ta_ids = []
    courses.each do |course|
      ta_mappings = TaMapping.where(course_id: course.id)
      ta_mappings.each {|mapping| ta_ids << mapping.ta_id } unless ta_mappings.empty?
    end
    ta_ids
  end

  def self.get_user_list(user)
    participants = []
    user_list = []
    # Refactor
    courses = Course.where(instructor_id: user.id)
    courses.each do |course|
      participants << course.get_participants
    end
    assignments = Assignment.where(instructor_id: user.id)
    assignments.each do |assignment|
      participants << assignment.participants
    end
    participants.each do |p_s|
      next if p_s.empty?
      p_s.each do |p|
        user_list << p.user if user.role.hasAllPrivilegesOf(p.user.role)
      end
    end
    user_list
  end
end
