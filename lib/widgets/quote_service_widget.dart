import 'dart:math';

class QuoteService {
  static final List<Map<String, String>> _quotes = [
    {
      'quote':
          'The best time to plant a tree was 20 years ago. The second best time is now.',
      'author': 'Chinese Proverb',
    },
    {
      'quote':
          'It does not matter how slowly you go as long as you do not stop.',
      'author': 'Confucius',
    },
    {
      'quote':
          'Our greatest glory is not in never falling, but in rising every time we fall.',
      'author': 'Confucius',
    },
    {
      'quote': 'The journey of a thousand miles begins with one step.',
      'author': 'Lao Tzu',
    },
    {
      'quote': 'In the middle of difficulty lies opportunity.',
      'author': 'Albert Einstein',
    },
    {
      'quote':
          'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'author': 'Winston Churchill',
    },
    {
      'quote': 'Believe you can and you\'re halfway there.',
      'author': 'Theodore Roosevelt',
    },
    {
      'quote': 'Act as if what you do makes a difference. It does.',
      'author': 'William James',
    },
    {
      'quote': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
    },
    {
      'quote': 'Life is what happens when you\'re busy making other plans.',
      'author': 'John Lennon',
    },
    {
      'quote': 'Be yourself; everyone else is already taken.',
      'author': 'Oscar Wilde',
    },
    {
      'quote':
          'Two things are infinite: the universe and human stupidity; and I\'m not sure about the universe.',
      'author': 'Albert Einstein',
    },
    {
      'quote': 'The only thing we have to fear is fear itself.',
      'author': 'Franklin D. Roosevelt',
    },
    {
      'quote': 'To be or not to be, that is the question.',
      'author': 'William Shakespeare',
    },
    {'quote': 'I think, therefore I am.', 'author': 'René Descartes'},
    {'quote': 'The unexamined life is not worth living.', 'author': 'Socrates'},
    {
      'quote': 'Wherever you go, go with all your heart.',
      'author': 'Confucius',
    },
    {
      'quote': 'Knowing yourself is the beginning of all wisdom.',
      'author': 'Aristotle',
    },
    {
      'quote':
          'It is during our darkest moments that we must focus to see the light.',
      'author': 'Aristotle',
    },
    {
      'quote': 'The only true wisdom is in knowing you know nothing.',
      'author': 'Socrates',
    },
  ];

  static Future<Map<String, String>> getRandomQuote() async {
    final random = Random();
    final index = random.nextInt(_quotes.length);
    return _quotes[index];
  }
}
