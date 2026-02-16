# Love Game - Flutter Web Application

A romantic Flutter Web game with interactive animations and email notifications.

## Features

### 🏠 Home Screen
- Centered text: "Please play till the end…"
- Large Start button with elegant styling

### 🎮 Main Game Screen
- Question: "Will you go out with me in the coming week?"
- Yes and No buttons with dynamic behaviors

### ✅ Yes Button Behavior
- Shows success screen with confetti animation
- Sends email notification to aliawan1170@gmail.com
- Includes click count in email

### ❌ No Button Behavior
- Tracks click count
- Progressive scaling: Yes button grows, No button shrinks
- Funny messages that change with each click
- After 11-12 clicks: No button moves randomly, becomes hard to click

### 🎨 Animations & UI
- Floating heart particles
- Button shake animations
- Bounce effects
- Pink/red romantic gradient theme
- Responsive design for mobile and desktop

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run on Chrome (Development)
```bash
flutter run -d chrome
```

### 3. Build for Web (Production)
```bash
flutter build web
```

The build output will be in the `build/web` directory.

## Email Configuration

### Using EmailJS (Recommended)

1. **Create EmailJS Account**
   - Go to [EmailJS](https://www.emailjs.com/)
   - Sign up for a free account

2. **Create Email Service**
   - Add your email service (Gmail, Outlook, etc.)
   - Note the Service ID

3. **Create Email Template**
   - Create a new template with variables:
     - `{{to_email}}` - Recipient email
     - `{{subject}}` - Email subject
     - `{{message}}` - Email content

4. **Update Code**
   Replace these placeholders in `lib/main.dart`:
   ```dart
   const String serviceId = 'your_service_id';
   const String templateId = 'your_template_id';
   const String userId = 'your_public_key';
   ```

### Alternative: Firebase Cloud Functions

1. **Set up Firebase Project**
   - Create Firebase project
   - Enable Cloud Functions

2. **Create Cloud Function**
   ```javascript
   const functions = require('firebase-functions');
   const nodemailer = require('nodemailer');

   exports.sendLoveGameEmail = functions.https.onCall(async (data, context) => {
     const transporter = nodemailer.createTransporter({
       service: 'gmail',
       auth: {
         user: 'your-email@gmail.com',
         pass: 'your-app-password'
       }
     });

     const mailOptions = {
       from: 'your-email@gmail.com',
       to: 'aliawan1170@gmail.com',
       subject: data.subject,
       text: data.message
     };

     await transporter.sendMail(mailOptions);
     return { success: true };
   });
   ```

3. **Update Flutter Code**
   Replace the `_sendEmail()` function to call your Firebase function.

## Game Mechanics

### Button Scaling
- **Yes Button**: Grows 10% per No click (max 2.5x)
- **No Button**: Shrinks 8% per No click (min 0.3x)

### No Button Messages
The No button displays progressively more desperate messages:
1. "Are you sure? 😢"
2. "Really? 🥺"
3. "Think again 💔"
4. "You can't escape destiny 😏"
5. "No is not an option"
... and more!

### Moving No Button
After 11 clicks, the No button:
- Moves to random positions
- Becomes very small
- Changes position immediately after being clicked

## Deployment

### Firebase Hosting (Recommended)
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Initialize Firebase: `firebase init hosting`
3. Deploy: `firebase deploy`

### Other Hosting Options
- **Netlify**: Drag and drop the `build/web` folder
- **Vercel**: Connect your Git repository
- **GitHub Pages**: Use GitHub Actions for automatic deployment

## File Structure
```
lib/
├── main.dart          # Main game logic
├── (other files)

pubspec.yaml           # Dependencies
web/                   # Web-specific files
build/web/            # Production build output
```

## Dependencies
- `flutter`: Flutter SDK
- `confetti`: Confetti animations
- `http`: HTTP requests for EmailJS
- `dart:math`: Mathematical operations
- `dart:convert`: JSON encoding

## Security Notes
- Email credentials are never exposed in the client code
- EmailJS uses public keys only (secure)
- Firebase Cloud Functions keep server-side logic private

## Troubleshooting

### Common Issues
1. **Email not sending**: Check EmailJS configuration
2. **Animations not smooth**: Ensure Chrome is updated
3. **Build errors**: Run `flutter clean` then `flutter pub get`

### Performance Tips
- Use Chrome for best performance
- Ensure hardware acceleration is enabled
- Test on different screen sizes

## Support
For issues or questions, please check the Flutter documentation or create an issue in your project repository.

---

Enjoy the game! 💕
