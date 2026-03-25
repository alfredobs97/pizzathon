import * as functions from "firebase-functions/v1";
import * as logger from "firebase-functions/logger";
import * as nodemailer from "nodemailer";

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

export const sendWelcomeEmail = functions.auth.user().onCreate(
  async (user: functions.auth.UserRecord) => {
    const emailDestino = user.email;
    const nombreUsuario = user.displayName || "nuevo usuario";

    if (!emailDestino) {
      logger.warn(`UID ${user.uid} sin email. Abortando.`);
      return null;
    }

    const mailOptions = {
      from: `"Equipo Pizzathon" <${process.env.EMAIL_USER}>`,
      to: emailDestino,
      subject: "¡Bienvenido a la plataforma!",
      text: `Hola ${nombreUsuario}, tu cuenta ha sido creada con éxito.`,
      html: `<b>Hola ${nombreUsuario}</b>,<br>` +
        "Tu cuenta ha sido creada con éxito. ¡Gracias por registrarte!",
    };

    try {
      await transporter.sendMail(mailOptions);
      logger.info(`Email enviado a ${emailDestino}`);
    } catch (error) {
      logger.error("Fallo al enviar el email:", error);
    }

    return null;
  }
);
