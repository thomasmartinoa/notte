/// KTU University data - Branches, Semesters, and Subjects
/// Based on APJ Abdul Kalam Technological University curriculum
library;

class KtuData {
  KtuData._();

  /// All engineering branches offered by KTU
  static const List<Branch> branches = [
    Branch(
      id: 'cse',
      name: 'Computer Science and Engineering',
      shortName: 'CSE',
      icon: 'computer',
    ),
    Branch(
      id: 'ece',
      name: 'Electronics and Communication Engineering',
      shortName: 'ECE',
      icon: 'memory',
    ),
    Branch(
      id: 'eee',
      name: 'Electrical and Electronics Engineering',
      shortName: 'EEE',
      icon: 'bolt',
    ),
    Branch(
      id: 'me',
      name: 'Mechanical Engineering',
      shortName: 'ME',
      icon: 'settings',
    ),
    Branch(
      id: 'ce',
      name: 'Civil Engineering',
      shortName: 'CE',
      icon: 'domain',
    ),
    Branch(
      id: 'it',
      name: 'Information Technology',
      shortName: 'IT',
      icon: 'code',
    ),
    Branch(
      id: 'csbs',
      name: 'Computer Science and Business Systems',
      shortName: 'CSBS',
      icon: 'business',
    ),
    Branch(
      id: 'aids',
      name: 'Artificial Intelligence and Data Science',
      shortName: 'AIDS',
      icon: 'psychology',
    ),
    Branch(
      id: 'aiml',
      name: 'Artificial Intelligence and Machine Learning',
      shortName: 'AIML',
      icon: 'smart_toy',
    ),
    Branch(
      id: 'cy',
      name: 'Cyber Security',
      shortName: 'CY',
      icon: 'security',
    ),
    Branch(
      id: 'ae',
      name: 'Aeronautical Engineering',
      shortName: 'AE',
      icon: 'flight',
    ),
    Branch(
      id: 'auto',
      name: 'Automobile Engineering',
      shortName: 'AUTO',
      icon: 'directions_car',
    ),
    Branch(
      id: 'bme',
      name: 'Biomedical Engineering',
      shortName: 'BME',
      icon: 'biotech',
    ),
    Branch(
      id: 'bt',
      name: 'Biotechnology',
      shortName: 'BT',
      icon: 'science',
    ),
    Branch(
      id: 'che',
      name: 'Chemical Engineering',
      shortName: 'CHE',
      icon: 'science',
    ),
    Branch(
      id: 'food',
      name: 'Food Technology',
      shortName: 'FOOD',
      icon: 'restaurant',
    ),
    Branch(
      id: 'ie',
      name: 'Instrumentation Engineering',
      shortName: 'IE',
      icon: 'speed',
    ),
    Branch(
      id: 'pe',
      name: 'Production Engineering',
      shortName: 'PE',
      icon: 'precision_manufacturing',
    ),
    Branch(
      id: 'rac',
      name: 'Refrigeration and Air Conditioning',
      shortName: 'RAC',
      icon: 'ac_unit',
    ),
    Branch(
      id: 'na',
      name: 'Naval Architecture',
      shortName: 'NA',
      icon: 'sailing',
    ),
    Branch(
      id: 'arch',
      name: 'Architecture',
      shortName: 'ARCH',
      icon: 'architecture',
    ),
    Branch(
      id: 'meta',
      name: 'Metallurgical Engineering',
      shortName: 'META',
      icon: 'hardware',
    ),
    Branch(
      id: 'poly',
      name: 'Polymer Engineering',
      shortName: 'POLY',
      icon: 'texture',
    ),
    Branch(
      id: 'safety',
      name: 'Safety and Fire Engineering',
      shortName: 'SAFETY',
      icon: 'local_fire_department',
    ),
  ];

  /// All 8 semesters
  static const List<Semester> semesters = [
    Semester(id: 's1', number: 1, name: 'Semester 1'),
    Semester(id: 's2', number: 2, name: 'Semester 2'),
    Semester(id: 's3', number: 3, name: 'Semester 3'),
    Semester(id: 's4', number: 4, name: 'Semester 4'),
    Semester(id: 's5', number: 5, name: 'Semester 5'),
    Semester(id: 's6', number: 6, name: 'Semester 6'),
    Semester(id: 's7', number: 7, name: 'Semester 7'),
    Semester(id: 's8', number: 8, name: 'Semester 8'),
  ];

  /// Common subjects for S1 & S2 (all branches)
  static const List<Subject> commonSubjectsS1 = [
    Subject(
      id: 'mat101',
      code: 'MAT101',
      name: 'Linear Algebra and Calculus',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'phy100',
      code: 'PHY100',
      name: 'Engineering Physics A',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cyt100',
      code: 'CYT100',
      name: 'Engineering Chemistry',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'est100',
      code: 'EST100',
      name: 'Engineering Mechanics',
      credits: 3,
      modules: 5,
    ),
    Subject(
      id: 'est110',
      code: 'EST110',
      name: 'Engineering Graphics',
      credits: 3,
      modules: 5,
    ),
    Subject(
      id: 'hun101',
      code: 'HUN101',
      name: 'Life Skills',
      credits: 2,
      modules: 4,
    ),
  ];

  static const List<Subject> commonSubjectsS2 = [
    Subject(
      id: 'mat102',
      code: 'MAT102',
      name: 'Vector Calculus, Differential Equations and Transforms',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'phy102',
      code: 'PHY102',
      name: 'Engineering Physics B',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'est102',
      code: 'EST102',
      name: 'Programming in C',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'est120',
      code: 'EST120',
      name: 'Basics of Civil and Mechanical Engineering',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'est130',
      code: 'EST130',
      name: 'Basics of Electrical and Electronics Engineering',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'hun102',
      code: 'HUN102',
      name: 'Professional Communication',
      credits: 2,
      modules: 4,
    ),
  ];

  /// CSE Subjects S3-S8 (sample, expand as needed)
  static const List<Subject> cseSubjectsS3 = [
    Subject(
      id: 'mat203',
      code: 'MAT203',
      name: 'Discrete Mathematical Structures',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst201',
      code: 'CST201',
      name: 'Data Structures',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst203',
      code: 'CST203',
      name: 'Logic System Design',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst205',
      code: 'CST205',
      name: 'Object Oriented Programming using Java',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'est200',
      code: 'EST200',
      name: 'Design and Engineering',
      credits: 3,
      modules: 4,
    ),
    Subject(
      id: 'mct201',
      code: 'MCT201',
      name: 'Sustainable Engineering',
      credits: 3,
      modules: 4,
    ),
  ];

  static const List<Subject> cseSubjectsS4 = [
    Subject(
      id: 'mat206',
      code: 'MAT206',
      name: 'Graph Theory',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst202',
      code: 'CST202',
      name: 'Computer Organization and Architecture',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst204',
      code: 'CST204',
      name: 'Database Management Systems',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst206',
      code: 'CST206',
      name: 'Operating Systems',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst208',
      code: 'CST208',
      name: 'Formal Languages and Automata Theory',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'mct202',
      code: 'MCT202',
      name: 'Constitution of India',
      credits: 2,
      modules: 4,
    ),
  ];

  static const List<Subject> cseSubjectsS5 = [
    Subject(
      id: 'cst301',
      code: 'CST301',
      name: 'Algorithm Analysis and Design',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst303',
      code: 'CST303',
      name: 'System Software',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst305',
      code: 'CST305',
      name: 'Computer Networks',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst307',
      code: 'CST307',
      name: 'Microprocessors and Microcontrollers',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst309',
      code: 'CST309',
      name: 'Management of Software Systems',
      credits: 3,
      modules: 4,
    ),
    Subject(
      id: 'hut300',
      code: 'HUT300',
      name: 'Industrial Economics and Foreign Trade',
      credits: 3,
      modules: 4,
    ),
  ];

  static const List<Subject> cseSubjectsS6 = [
    Subject(
      id: 'cst302',
      code: 'CST302',
      name: 'Compiler Design',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst304',
      code: 'CST304',
      name: 'Computer Graphics and Image Processing',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst306',
      code: 'CST306',
      name: 'Algorithm Analysis and Design (Honours)',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst308',
      code: 'CST308',
      name: 'Comprehensive Course Work',
      credits: 3,
      modules: 4,
    ),
    Subject(
      id: 'csd334',
      code: 'CSD334',
      name: 'Mobile Application Development Lab',
      credits: 2,
      modules: 3,
    ),
  ];

  static const List<Subject> cseSubjectsS7 = [
    Subject(
      id: 'cst401',
      code: 'CST401',
      name: 'Artificial Intelligence',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst403',
      code: 'CST403',
      name: 'Cryptography and Network Security',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'csd411',
      code: 'CSD411',
      name: 'Seminar',
      credits: 2,
      modules: 1,
    ),
    Subject(
      id: 'csd413',
      code: 'CSD413',
      name: 'Project Phase 1',
      credits: 2,
      modules: 1,
    ),
  ];

  static const List<Subject> cseSubjectsS8 = [
    Subject(
      id: 'cst402',
      code: 'CST402',
      name: 'Distributed Computing',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'cst404',
      code: 'CST404',
      name: 'Machine Learning',
      credits: 4,
      modules: 5,
    ),
    Subject(
      id: 'csd414',
      code: 'CSD414',
      name: 'Project Phase 2',
      credits: 8,
      modules: 1,
    ),
  ];

  /// Get subjects for a branch and semester
  static List<Subject> getSubjects(String branchId, int semester) {
    // For S1 and S2, all branches have common subjects
    if (semester == 1) return commonSubjectsS1;
    if (semester == 2) return commonSubjectsS2;

    // For S3 onwards, return branch-specific subjects
    // Currently only CSE is fully populated, others can be added
    if (branchId == 'cse') {
      switch (semester) {
        case 3:
          return cseSubjectsS3;
        case 4:
          return cseSubjectsS4;
        case 5:
          return cseSubjectsS5;
        case 6:
          return cseSubjectsS6;
        case 7:
          return cseSubjectsS7;
        case 8:
          return cseSubjectsS8;
        default:
          return [];
      }
    }

    // TODO: Add subjects for other branches
    return [];
  }

  /// Get branch by ID
  static Branch? getBranch(String id) {
    try {
      return branches.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get semester by number
  static Semester? getSemester(int number) {
    try {
      return semesters.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }
}

/// Branch model
class Branch {
  final String id;
  final String name;
  final String shortName;
  final String icon;

  const Branch({
    required this.id,
    required this.name,
    required this.shortName,
    required this.icon,
  });
}

/// Semester model
class Semester {
  final String id;
  final int number;
  final String name;

  const Semester({
    required this.id,
    required this.number,
    required this.name,
  });
}

/// Subject model
class Subject {
  final String id;
  final String code;
  final String name;
  final int credits;
  final int modules;

  const Subject({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    required this.modules,
  });
}
