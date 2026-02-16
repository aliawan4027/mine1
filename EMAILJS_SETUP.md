# EmailJS Setup Guide

This guide will help you set up EmailJS to send email notifications from your Flutter Love Game.

## Step 1: Create EmailJS Account

1. Go to [https://www.emailjs.com/](https://www.emailjs.com/)
2. Click **"Sign Up"** and create a free account
3. Verify your email address

## Step 2: Create Email Service

1. After logging in, go to **"Email Services"** in the dashboard
2. Click **"Add New Service"**
3. Choose your email provider (Gmail is recommended)
4. Follow the connection instructions:
   - For Gmail: Click "Connect" and sign in with your Google account
   - Grant EmailJS permission to send emails on your behalf
5. Give your service a name (e.g., "gmail_service")
6. Note down your **Service ID** (it will look like: `service_xxxxxxxxx`)

## Step 3: Create Email Template

1. Go to **"Email Templates"** in the dashboard
2. Click **"Create New Template"**
3. Fill in the template details:

**Template Name:** `Love Game Notification`

**Subject:** `{{subject}}`

**Email Content:**
```
{{message}}
```

4. Your template should look like this:
```html
<h2>{{subject}}</h2>
<p>{{message}}</p>
```

5. Click **"Save"**
6. Note down your **Template ID** (it will look like: `template_xxxxxxxxx`)

## Step 4: Get Your Public Key

1. Go to **"Account"** → **"General"** 
2. Find your **Public Key** (it will look like: `xxxxxxxxxxxxxxxxxxxx`)
3. Copy this key

## Step 5: Update Your Flutter Code

Open `lib/main.dart` and replace the placeholder values with your actual EmailJS credentials:

```dart
// Replace these with your actual EmailJS credentials
const String serviceId = 'service_your_actual_service_id';
const String templateId = 'template_your_actual_template_id';
const String userId = 'your_actual_public_key';
```

## Step 6: Test Your Setup

1. Run your Flutter app:
   ```bash
   flutter run -d chrome
   ```

2. Play the game and click "Yes"
3. Check your email (and spam folder) for the notification

## Example Configuration

After setup, your code should look like this:

```dart
// EmailJS configuration
const String serviceId = 'service_abc123def456';
const String templateId = 'template_xyz789uvw012';
const String userId = 'abcdefghijklmnopqrstuv';
```

## Troubleshooting

### Email Not Sending

1. **Check Console**: Open browser dev tools and check for error messages
2. **Verify Credentials**: Ensure all IDs are correctly copied
3. **Check Template**: Make sure template variables match (`{{subject}}`, `{{message}}`)
4. **Email Service**: Ensure your email service is properly connected

### Common Errors

- **401 Unauthorized**: Check your public key
- **400 Bad Request**: Check your service ID and template ID
- **CORS Issues**: EmailJS handles this automatically, but ensure you're using HTTPS in production

## Security Notes

✅ **Safe**: Only public keys are exposed in client code
✅ **Secure**: EmailJS handles email sending server-side
✅ **Free Plan**: 200 emails/month on free tier

## Alternative: Using Gmail App Password

If you prefer not to use EmailJS, you can use Gmail with App Passwords:

1. Enable 2-factor authentication on your Gmail account
2. Generate an App Password
3. Use a backend service (Firebase Functions) to send emails

However, EmailJS is recommended for simplicity and security.

## Need Help?

- EmailJS Documentation: [https://www.emailjs.com/docs/](https://www.emailjs.com/docs/)
- Flutter HTTP Package: [https://pub.dev/packages/http](https://pub.dev/packages/http)

---

Once set up, your Love Game will send cute email notifications whenever someone says "Yes"! 💕
