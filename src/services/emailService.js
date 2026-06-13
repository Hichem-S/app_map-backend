const nodemailer = require("nodemailer");

const mailer = nodemailer.createTransport({
  host:    process.env.SMTP_HOST || "smtp.gmail.com",
  port:    parseInt(process.env.SMTP_PORT || "587"),
  secure:  false,
  requireTLS: true,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

const sendMail = (to, subject, html) =>
  mailer.sendMail({ from: process.env.SMTP_USER, to, subject, html });

module.exports = { sendMail };
