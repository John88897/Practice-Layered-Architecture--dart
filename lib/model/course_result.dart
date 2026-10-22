import 'package:lms_layered_architecture_example/model/course.dart';
import 'package:lms_layered_architecture_example/model/student.dart';

class CourseResult {
  final int id;
  final int score;
  final Course course;
  final Student student;

  CourseResult(
      {required this.id,
      required this.score,
      required this.course,
      required this.student});
}
