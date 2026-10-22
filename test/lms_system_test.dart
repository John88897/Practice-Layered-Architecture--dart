import 'dart:math';

import 'package:lms_layered_architecture_example/model/course.dart';
import 'package:lms_layered_architecture_example/model/course_result.dart';
import 'package:lms_layered_architecture_example/service/lms_system.dart';
import 'package:test/test.dart';

void main() {
  test('creates a student', () {
    final lms = LmsSystem();

    // Create a student
    lms.addStudent(studentId: 'S1', studentName: "ronan");

    expect(lms.students.first.name, 'ronan');

    // Remove the student
    lms.removeStudent(studentId: 'S1');
    expect(lms.students.length, 0);

    // add and remove course
  });
// task 1
  test('add and remove course', () {
    final lms = LmsSystem();
    // add course and reject duplicate couse
    lms.addCourse(courseId: 'C1', courseName: 'Dart');
    expect(() => lms.addCourse(courseId: 'C1', courseName: 'Flutter'),
        throwsException);

    // remove course and remove nonexistend course
    lms.removeCourse(courseId: 'C1');
    expect(() => lms.removeCourse(courseId: 'C2'), throwsException);
  });

// task 2
  test('enroll student to course', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: "ronan");
    expect(lms.students.length, 1);
    lms.addCourse(courseId: 'C1', courseName: 'Dart');
    expect(lms.courses.length, 1);

    // enroll existing student in existing course
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    expect(lms.courses.first.studentIds.length, 1);
    expect(() => lms.enrollStudent(studentId: 'S2', courseId: 'C1'),
        throwsException);
    expect(() => lms.enrollStudent(studentId: 'S1', courseId: 'C2'),
        throwsException);

    expect(() => lms.enrollStudent(studentId: 'S1', courseId: 'C1'),
        throwsException);
  });

// task 3
  test('remove student from course', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: "Ronan");
    lms.addStudent(studentId: 'S3', studentName: 'John');
    lms.addCourse(courseId: 'C1', courseName: 'Dart');
    lms.addCourse(courseId: 'C3', courseName: 'Backend');

    lms.enrollStudent(studentId: 'S1', courseId: 'C1');

    lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');
    //remove existing enrollment
    expect(lms.findCourseOrNull('C1')!.studentIds, isEmpty);
    // reject removal nonexisting enrollment
    expect(() => lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C3'),
        throwsException);
    // verify student and course still exist
    expect(lms.students.length, 2);
    expect(lms.courses.length, 2);
    // Verify the chosen policy for associated results
    // test removing student who has enrollments in multiple courses
    lms.enrollStudent(studentId: 'S3', courseId: 'C1');
    lms.enrollStudent(studentId: 'S3', courseId: 'C3');
    lms.results.add(CourseResult(
        id: 1,
        score: 80,
        course: lms.findCourseOrNull('C1')!,
        student: lms.students[1]));
    lms.results.add(CourseResult(
        id: 2,
        score: 89,
        course: lms.findCourseOrNull('C3')!,
        student: lms.students[1]));
    lms.discardStudentFromCourse(studentId: 'S3', courseId: 'C3');
    lms.results.add(CourseResult(
        id: 3,
        score: 90,
        course: lms.findCourseOrNull('C1')!,
        student: lms.students.first));
    expect(lms.results.length, 2);
    expect(lms.results.first.course.id, 'C1');

    lms.removeStudent(studentId: 'S3');

    //student s3 is gone s1 remains
    expect(lms.students.length, 1);
    expect(lms.students.first.id, 'S1');
    // s3 remove from every courses
    expect(lms.findCourseOrNull('C1')!.studentIds, isEmpty);
    expect(lms.findCourseOrNull('C3')!.studentIds, isEmpty);
  });

// task 4
  group('Add result to course', () {
    late LmsSystem lms;
    setUp(() {
      lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addStudent(studentId: 'S2', studentName: 'John');
      lms.addCourse(courseId: 'C1', courseName: 'Dart');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    });

    test('add a vallid result', () {
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 80);

      expect(lms.results.length, 1);
      expect(lms.results.first.score, 80);
      expect(lms.results.first.student.id, 'S1');
      expect(lms.results.first.course.id, 'C1');
    });

    test('reject result for nonexisting student or course', () {
      expect(() => lms.addResult(studentId: 'S3', courseId: 'C1', score: 90),
          throwsException);
      expect(lms.results, isEmpty);
      expect(() => lms.addResult(studentId: 'S1', courseId: 'C3', score: 90),
          throwsException);
      expect(lms.results, isEmpty);
    });

    test(
        'reject a result for a student who is not enrolled, if enrollment is required',
        () {
      expect(() => lms.addResult(studentId: 'S9', courseId: 'C1', score: 60),
          throwsException);
      expect(lms.results, isEmpty);
    });

    test('reject invalid score', () {
      expect(() => lms.addResult(studentId: 'S1', courseId: 'C1', score: -13),
          throwsException);
      expect(lms.results, isEmpty);
      expect(() => lms.addResult(studentId: 'S1', courseId: 'C1', score: 120),
          throwsException);
      expect(lms.results, isEmpty);
    });

    test('test duplicate result', () {
      final id1 = lms.addResult(studentId: 'S1', courseId: 'C1', score: 80);
      final id2 = lms.addResult(studentId: 'S1', courseId: 'C1', score: 90);

      expect(lms.results.length, 2);
      expect(id1, isNot(id2));
    });
  });

// task 5
  group('remove student result', () {
    late LmsSystem lms;
    late int r1;
    late int r2;
    setUp(() {
      lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addStudent(studentId: 'S2', studentName: 'John');
      lms.addCourse(courseId: 'C1', courseName: 'Dart');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');
      r1 = lms.addResult(studentId: 'S1', courseId: 'C1', score: 80);
      r2 = lms.addResult(studentId: 'S2', courseId: 'C1', score: 88);
    });
    test('remove an existing result', () {
      lms.removeResult(resultId: r1);
      expect(lms.results.length, 1);
    });
    test('reject nonexisting result', () {
      expect(() => lms.removeResult(resultId: 4), throwsException);
      expect(lms.results.length, 2);
    });
    test('verify result no longer available', () {
      lms.removeResult(resultId: r1);
      expect(lms.results.any((r) => r.id == r1), false);
      expect(() => lms.removeResult(resultId: r1), throwsException);
    });
    test('verify that student, course and unrelated result remain unchanged',
        () {
      lms.removeResult(resultId: r1);
      expect(lms.students.length, 2);
      expect(lms.courses.length, 1);
      expect( lms.findCourseOrNull('C1')!.studentIds, ['S1', 'S2']);
      expect(lms.results.length, 1);
      expect(lms.results.first.id, r2);
      expect(lms.results.first.score, 88);
      expect(lms.results.first.student.id, 'S2');
    });
  });
}
