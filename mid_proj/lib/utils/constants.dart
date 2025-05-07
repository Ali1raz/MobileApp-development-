final Map<String, Map<String, dynamic>> difficultySettings = {
  'Easy': {
    'min': 1,
    'max': 10,
    'ops': ['+', '-'],
    'level': 'Easy',
  },
  'Medium': {
    'min': 1,
    'max': 50,
    'ops': ['+', '-', 'x', '÷'],
    'level': 'Medium',
  },
  'Hard': {
    'min': 1,
    'max': 100,
    'ops': ['+', '-', '×', '÷'],
    'level': 'Hard',
  },
};

final List<String> operators = ['+', '-', '×', '÷'];

final List<String> gameTypes = ['Test', 'True / False', 'Input'];
