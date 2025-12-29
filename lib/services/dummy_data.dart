// lib/services/dummy_data.dart

import '../models/lesson.dart';  // Import from models folder
import '../models/quiz.dart';    // Import from models folder

class DummyData {
  // EXPANDED SUBJECT LIST
  static List<Map<String, dynamic>> subjects = [
    {
      "id": "math",
      "name": "Mathematics",
      "icon": "📘",
    },
    {
      "id": "english",
      "name": "English",
      "icon": "📚",
    },
    {
      "id": "physics",
      "name": "Physics",
      "icon": "⚛️",
    },
    {
      "id": "chemistry",
      "name": "Chemistry",
      "icon": "🧪",
    },
    {
      "id": "biology",
      "name": "Biology",
      "icon": "🧬",
    },
    {
      "id": "computer_science",
      "name": "Computer Science",
      "icon": "💻",
    },
    {
      "id": "history",
      "name": "History",
      "icon": "🏛️",
    },
    {
      "id": "geography",
      "name": "Geography",
      "icon": "🌍",
    },
    {
      "id": "music",
      "name": "Music",
      "icon": "🎵",
    },
    {
      "id": "economics",
      "name": "Economics",
      "icon": "📈",
    },
  ];

  // LESSONS FOR EACH SUBJECT (Add lessons for new subjects)
  static Map<String, List<Lesson>> lessons = {
    "math": [
      Lesson(
        id: "math1",
        title: "Introduction to Algebra",
        description: "Learn the basics of algebra, variables, and equations.",
        content:
            "Algebra is a branch of mathematics that uses symbols to represent numbers...",
      ),
      Lesson(
        id: "math2",
        title: "Basic Geometry",
        description: "Understanding shapes, angles, and measurements.",
        content: "Geometry deals with the study of shapes, lines, angles...",
      ),
    ],
    "english": [
      Lesson(
        id: "eng1",
        title: "Nouns and Pronouns",
        description: "Basics of naming words and replacements.",
        content: "A noun is the name of a person, place, or thing...",
      ),
      Lesson(
        id: "eng2",
        title: "Sentence Structure",
        description: "How to form correct English sentences.",
        content: "A sentence must have a subject and a predicate...",
      ),
    ],

    "physics": [
      Lesson(
        id: "phy1",
        title: "Laws of Motion",
        description: "Newton's three laws of motion explained.",
        content: "Newton's First Law: An object at rest stays at rest...",
      ),
      Lesson(
        id: "phy2",
        title: "Electricity Basics",
        description: "Introduction to electric circuits and current.",
        content: "Electricity is the flow of electric charge...",
      ),
    ],

    "chemistry": [
      Lesson(
        id: "chem1",
        title: "Atomic Structure",
        description: "Understanding atoms, protons, neutrons, and electrons.",
        content: "Atoms are the basic building blocks of matter...",
      ),
      Lesson(
        id: "chem2",
        title: "Chemical Reactions",
        description: "Types of chemical reactions and equations.",
        content: "A chemical reaction involves rearrangement of atoms...",
      ),
    ],

    "biology": [
      Lesson(
        id: "bio1",
        title: "Cell Structure",
        description: "Learn about plant and animal cells.",
        content: "Cells are the basic unit of life...",
      ),
      Lesson(
        id: "bio2",
        title: "Photosynthesis",
        description: "How plants make their own food.",
        content: "Photosynthesis is the process by which plants convert light energy...",
      ),
    ],

    "computer_science": [
      Lesson(
        id: "cs1",
        title: "Introduction to Programming",
        description: "Basics of programming concepts and algorithms.",
        content: "Programming is the process of creating instructions for computers...",
      ),
      Lesson(
        id: "cs2",
        title: "Data Structures",
        description: "Understanding arrays, lists, and trees.",
        content: "Data structures organize and store data efficiently...",
      ),
    ],

    "history": [
      Lesson(
        id: "his1",
        title: "Ancient Civilizations",
        description: "Learn about Egypt, Greece, and Rome.",
        content: "Ancient civilizations laid the foundation for modern society...",
      ),
      Lesson(
        id: "his2",
        title: "World Wars",
        description: "Causes and consequences of World War I & II.",
        content: "The World Wars were global conflicts that reshaped the world...",
      ),
    ],

    "geography": [
      Lesson(
        id: "geo1",
        title: "Continents and Oceans",
        description: "Learn about Earth's major landforms and water bodies.",
        content: "Earth has 7 continents and 5 oceans...",
      ),
      Lesson(
        id: "geo2",
        title: "Climate Zones",
        description: "Understanding different climate patterns.",
        content: "Climate zones are regions with similar weather patterns...",
      ),
    ],
    "music": [
      Lesson(
        id: "mus1",
        title: "Musical Notes",
        description: "Learn about notes, scales, and rhythms.",
        content: "Musical notes are the building blocks of music...",
      ),
      Lesson(
        id: "mus2",
        title: "Music Genres",
        description: "Understanding different styles of music.",
        content: "Music genres categorize music based on style and form...",
      ),
    ],

    "economics": [
      Lesson(
        id: "econ1",
        title: "Supply and Demand",
        description: "Basic principles of market economics.",
        content: "Supply and demand determine prices in a market economy...",
      ),
      Lesson(
        id: "econ2",
        title: "Types of Economies",
        description: "Capitalism, socialism, and mixed economies.",
        content: "Economic systems determine how resources are allocated...",
      ),
    ],
  };

  // QUIZ DATA (Add quizzes for new subjects)
  static Map<String, List<Quiz>> quizzes = {
    "math": [
      Quiz(
        question: "What is 2 + 2?",
        options: ["2", "4", "6", "8"],
        correctAnswer: "4",
      ),
      Quiz(
        question: "Which is a variable in Algebra?",
        options: ["x", "5", "10", "="],
        correctAnswer: "x",
      ),
    ],

    "science": [
      Quiz(
        question: "What is the force that pulls objects to the ground?",
        options: ["Gravity", "Friction", "Air", "Pressure"],
        correctAnswer: "Gravity",
      ),
      Quiz(
        question: "Which organ digests food?",
        options: ["Heart", "Stomach", "Brain", "Lungs"],
        correctAnswer: "Stomach",
      ),
    ],

    "english": [
      Quiz(
        question: "A noun is a…?",
        options: ["Feeling", "Action", "Name", "Sound"],
        correctAnswer: "Name",
      ),
      Quiz(
        question: "Select a pronoun:",
        options: ["John", "He", "Book", "Water"],
        correctAnswer: "He",
      ),
    ],

    "physics": [
      Quiz(
        question: "What is the unit of force?",
        options: ["Newton", "Joule", "Watt", "Pascal"],
        correctAnswer: "Newton",
      ),
      Quiz(
        question: "Which color has the longest wavelength?",
        options: ["Red", "Blue", "Green", "Violet"],
        correctAnswer: "Red",
      ),
    ],

    "chemistry": [
      Quiz(
        question: "What is H₂O?",
        options: ["Water", "Hydrogen", "Oxygen", "Carbon Dioxide"],
        correctAnswer: "Water",
      ),
      Quiz(
        question: "What is the atomic number of Carbon?",
        options: ["6", "12", "14", "8"],
        correctAnswer: "6",
      ),
    ],

    "biology": [
      Quiz(
        question: "What is the powerhouse of the cell?",
        options: ["Nucleus", "Mitochondria", "Ribosome", "Cell Membrane"],
        correctAnswer: "Mitochondria",
      ),
      Quiz(
        question: "Which gas do plants absorb?",
        options: ["Oxygen", "Carbon Dioxide", "Nitrogen", "Hydrogen"],
        correctAnswer: "Carbon Dioxide",
      ),
    ],

    "computer_science": [
      Quiz(
        question: "What does CPU stand for?",
        options: [
          "Central Processing Unit",
          "Computer Personal Unit",
          "Central Power Unit",
          "Computer Processing Unit"
        ],
        correctAnswer: "Central Processing Unit",
      ),
      Quiz(
        question: "Which is a programming language?",
        options: ["Python", "HTML", "CSS", "XML"],
        correctAnswer: "Python",
      ),
    ],

    "history": [
      Quiz(
        question: "Who was the first President of the United States?",
        options: [
          "Thomas Jefferson",
          "Abraham Lincoln",
          "George Washington",
          "John Adams"
        ],
        correctAnswer: "George Washington",
      ),
      Quiz(
        question: "Which ancient civilization built the pyramids?",
        options: ["Greeks", "Romans", "Egyptians", "Mayans"],
        correctAnswer: "Egyptians",
      ),
    ],

    "geography": [
      Quiz(
        question: "Which is the largest continent?",
        options: ["Africa", "Europe", "Asia", "North America"],
        correctAnswer: "Asia",
      ),
      Quiz(
        question: "Which ocean is the largest?",
        options: [
          "Atlantic Ocean",
          "Indian Ocean",
          "Arctic Ocean",
          "Pacific Ocean"
        ],
        correctAnswer: "Pacific Ocean",
      ),
    ],

    "art": [
      Quiz(
        question: "Which are primary colors?",
        options: [
          "Red, Blue, Yellow",
          "Red, Green, Blue",
          "Orange, Green, Purple",
          "Black, White, Gray"
        ],
        correctAnswer: "Red, Blue, Yellow",
      ),
      Quiz(
        question: "Who painted the Mona Lisa?",
        options: [
          "Vincent van Gogh",
          "Pablo Picasso",
          "Leonardo da Vinci",
          "Michelangelo"
        ],
        correctAnswer: "Leonardo da Vinci",
      ),
    ],

    "music": [
      Quiz(
        question: "How many notes are in an octave?",
        options: ["7", "8", "12", "5"],
        correctAnswer: "8",
      ),
      Quiz(
        question: "Which instrument has strings?",
        options: ["Flute", "Trumpet", "Violin", "Drums"],
        correctAnswer: "Violin",
      ),
    ],

    "economics": [
      Quiz(
        question: "What does GDP stand for?",
        options: [
          "Gross Domestic Product",
          "General Domestic Profit",
          "Gross Domestic Price",
          "General Development Product"
        ],
        correctAnswer: "Gross Domestic Product",
      ),
      Quiz(
        question: "What is inflation?",
        options: [
          "Increase in prices",
          "Decrease in prices",
          "Increase in employment",
          "Decrease in taxes"
        ],
        correctAnswer: "Increase in prices",
      ),
    ],
  };

  static List<Quiz> getQuizzesByLesson(String lessonId) {
    // Extract the subject ID from the lesson ID (e.g., "math1" -> "math")
    String subjectId = lessonId.replaceAll(RegExp(r'\d+'), '');
    return quizzes[subjectId] ?? [];
  }
}