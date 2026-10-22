
class Course {
  final String id;
  final String name;
  final List<String> studentIds = [];

  Course({required this.id, required this.name});

  bool isEnroll({required String studentid}) {
    for (var id in studentIds) {
      if (id == studentid) {
        return true;
      }
    }
    return false;
  }
}
