require('dotenv').config();
const nodemailer = require('nodemailer');

const user = process.env.SMTP_USER;
const pass = process.env.SMTP_PASS;
const to   = process.argv[2] || user; // send to self if no arg

if (!user || user.includes('YOUR_GMAIL')) {
  console.error('\n❌  SMTP_USER is not set in .env');
  console.error('   Open .env and replace YOUR_GMAIL@gmail.com with your real Gmail address\n');
  process.exit(1);
}
if (!pass || pass.includes('xxxx')) {
  console.error('\n❌  SMTP_PASS is not set in .env');
  console.error('   Steps to get an App Password:');
  console.error('   1. Go to https://myaccount.google.com/security');
  console.error('   2. Enable 2-Step Verification');
  console.error('   3. Go to https://myaccount.google.com/apppasswords');
  console.error('   4. App: Mail  |  Device: Other → type "ISET Inventory" → Generate');
  console.error('   5. Copy the 16-char password into SMTP_PASS in .env\n');
  process.exit(1);
}

console.log(`\n📧  Testing SMTP connection...`);
console.log(`    Host : ${process.env.SMTP_HOST}`);
console.log(`    Port : ${process.env.SMTP_PORT}`);
console.log(`    User : ${user}`);
console.log(`    To   : ${to}\n`);

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: false,
  auth: { user, pass },
});

transporter.verify((err) => {
  if (err) {
    console.error('❌  Connection failed:', err.message);
    if (err.message.includes('535') || err.message.includes('Username and Password')) {
      console.error('\n   → Wrong credentials. Make sure you used an App Password,');
      console.error('     not your regular Gmail password.');
      console.error('     Get one at: https://myaccount.google.com/apppasswords\n');
    } else if (err.message.includes('ECONNREFUSED')) {
      console.error('\n   → Cannot reach smtp.gmail.com — check your internet connection.\n');
    }
    process.exit(1);
  }

  console.log('✅  SMTP connection OK — sending test email...\n');

  transporter.sendMail({
    from: `"Smart Inventory ISET" <${user}>`,
    to,
    subject: 'ISET Inventory — email test ✅',
    html: `
      <div style="font-family:sans-serif;max-width:480px;margin:auto">
        <h2 style="color:#4F46E5">Email is working!</h2>
        <p>Your SMTP configuration is correct. Verification codes will be sent to this address.</p>
      </div>
    `,
  }, (sendErr, info) => {
    if (sendErr) {
      console.error('❌  Send failed:', sendErr.message);
      process.exit(1);
    }
    console.log('✅  Email sent successfully!');
    console.log('   Message ID:', info.messageId);
    console.log('\n   Check your inbox for the test message.\n');
    process.exit(0);
  });
});
