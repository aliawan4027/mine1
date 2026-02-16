# Quick Email Setup for Dinner Game

Since EmailJS requires setup, here are 3 EASY ways to get email notifications working:

## Option 1: Formspree (Easiest - 5 minutes)

1. Go to [https://formspree.io/](https://formspree.io/)
2. Sign up for free account
3. Create a new form
4. Copy your form ID (looks like: `xqkwdzvp`)
5. Replace `your_form_id` in the code with your ID

```dart
// In main.dart, line 123, replace:
Uri.parse('https://formspree.io/f/your_form_id'),
// With your actual form ID:
Uri.parse('https://formspree.io/f/xqkwdzvp'),
```

## Option 2: Use Your Gmail Directly

1. Enable 2-factor authentication on clashwithme1122@gmail.com
2. Generate an App Password:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate new app password
3. Use this simple email service:

Replace the email function with:
```dart
Future<void> _sendEmail() async {
  try {
    final response = await http.post(
      Uri.parse('https://api.smtp2go.com/v3/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'api_key': 'your_smtp2go_key', // Get free key from smtp2go.com
        'to': ['aliawan1170@gmail.com'],
        'sender': 'clashwithme1122@gmail.com',
        'subject': 'Dinner Response! 🍽️',
        'text_body': 'She said YES to dinner!\n\nNo clicks: $_noClickCount\n\nTime to eat! 🎉',
      }),
    );
    
    if (response.statusCode == 200) {
      print('Email sent!');
    }
  } catch (e) {
    print('Email failed: $e');
  }
}
```

## Option 3: Web3Forms (Free & Simple)

1. Go to [https://web3forms.com/](https://web3forms.com/)
2. Get your free API key
3. Replace email function with:

```dart
Future<void> _sendEmail() async {
  try {
    final response = await http.post(
      Uri.parse('https://api.web3forms.com/submit'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'access_key': 'your_web3forms_key',
        'email': 'aliawan1170@gmail.com',
        'subject': 'Dinner Response! 🍽️',
        'message': 'She said YES to dinner!\n\nNo clicks: $_noClickCount\n\nTime to eat! 🎉',
      }),
    );
    
    if (response.statusCode == 200) {
      print('Email sent successfully!');
    }
  } catch (e) {
    print('Email failed: $e');
  }
}
```

## Fastest Solution - Use Formspree:

1. Sign up at formspree.io (2 minutes)
2. Create form (1 minute) 
3. Copy form ID (10 seconds)
4. Update one line in code (30 seconds)

**Total time: Less than 5 minutes!**

## Test Your Email Setup:

1. Run the game: `flutter run -d chrome`
2. Click "Yes"
3. Check your email inbox

The game will work perfectly even if email doesn't work - you'll just miss the notification.

## Game Changes Made:
✅ Changed from romantic to casual dinner invitation
✅ Updated all messages to be food-focused
✅ Added multiple email backup methods
✅ Made it less pressure, more casual

Now it's just about getting food together, not romance! 🍕🍔🍝
