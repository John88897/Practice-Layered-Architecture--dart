import 'package:lms_layered_architecture_example/model/course.dart';
import 'package:lms_layered_architecture_example/model/course_result.dart';

import '../model/student.dart';

class LmsSystem {
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<CourseResult> results = [];
  int _nextResultId = 1;
  void addStudent({required String studentId, required String studentName}) {
    // ! Student shall not exist already
    Student? student = _findStudentOrNull(studentId);
    if (student != null) {
      throw Exception('Student $student already exists');
    }

    students.add(Student(id: studentId, name: studentName));
  }

  void removeStudent({required String studentId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }
    // remove student from every courses
    for (final course in courses) {
      course.studentIds.remove(studentId);
    }
    // delete all of their result
    results.removeWhere((r) => r.student.id == studentId);
    // 1- Remove student from the students list
    students.removeWhere((student) => student.id == studentId);
  }

  Student? _findStudentOrNull(String studentId) {
    for (Student s in students) {
      if (s.id == studentId) {
        return s;
      }
    }
    return null; // not found
  }

  // task 1 - add and remove courses
  Course? findCourseOrNull(String courseId) {
    for (Course c in courses) {
      if (c.id == courseId) {
        return c;
      }
    }
    return null;
  }

  void addCourse({required String courseId, required String courseName}) {
    Course? course = findCourseOrNull(courseId);
    if (course != null) {
      throw Exception('Course $courseId already exist');
    }
    courses.add(Course(id: courseId, name: courseName));
  }

  void removeCourse({required String courseId}) {
    Course? course = findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found.');
    }
    courses.removeWhere((course) => course.id == courseId);
  }

  // task 2 - Enroll a student in a course
  void enrollStudent({required String studentId, required String courseId}) {
    Student? student = _findStudentOrNull(studentId);
    Course? course = findCourseOrNull(courseId);
    if (student == null) {
      throw Exception('student $studentId does not exist.');
    }
    if (course == null) {
      throw Exception('course $courseId not found.');
    }
    if (course.isEnroll(studentid: studentId) == true) {
      throw Exception('Student $studentId already enroll in course $courseId');
    }
    course.studentIds.add(studentId);
  }

  // task 3 - remove student from course
  void discardStudentFromCourse(
      {required String studentId, required String courseId}) {
    Course? course = findCourseOrNull(courseId);
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('student $studentId does not exist.');
    }
    if (course == null) {
      throw Exception('course $courseId not found.');
    }
    if (course.isEnroll(studentid: studentId) == false) {
      throw Exception('not found student $studentId in course $courseId');
    }

    results.removeWhere(
      (r) => r.student.id == studentId && r.course.id == courseId,
    );
    course.studentIds.remove(studentId);
  }

  // task 4
  int addResult(
      {required String studentId,
      required String courseId,
      required int score}) {
    Course? course = findCourseOrNull(courseId);
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('student $studentId not found');
    }
    if (course == null) {
      throw Exception('coures $courseId not found');
    }
    if (course.isEnroll(studentid: studentId) == false) {
      throw Exception('student $studentId not found in course $courseId');
    }
    if (score < 0 || score > 100) {
      throw Exception('Score must be 0-100');
    }
    final id = _nextResultId++;
    results.add(
        CourseResult(id: id, score: score, course: course, student: student));
    return id;
  }

  // task 5
  void removeResult({required int resultId}) {
    final exist = results.any((r) => r.id == resultId);

    if (!exist) {
      throw Exception('result $resultId not found');
    }
    results.removeWhere((r) => r.id == resultId);
  }
}
