import * as nodemailer from "nodemailer";

export const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

export const FROM_ADDRESS = `"Equipo Pizzathon" <${process.env.EMAIL_USER}>`;
