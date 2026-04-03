import * as logger from "firebase-functions/logger";
import * as nodemailer from "nodemailer";
import { onDocumentWritten } from "firebase-functions/firestore";

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

const userCollection = "users_2026_05";

export const sendWelcomeEmail = onDocumentWritten(
  `${userCollection}/{userId}`,
  async (event) => {
    const snapshot = event.data?.before;

    const emailDestino = snapshot?.data()?.email;
    const nombreUsuario = snapshot?.data()?.displayName || "nuevo usuario";

    if (!emailDestino) {
      logger.warn(`UID ${event.params.userId} sin email. Abortando.`);
      return null;
    }

    const mailOptions = {
      from: `"Equipo Pizzathon" <${process.env.EMAIL_USER}>`,
      to: emailDestino,
      subject: "Confirmación para tu inscripción a Pizzathon",
      text: `Hola ${nombreUsuario},\n\nTu inscripción a Pizzathon ha sido aceptada y a partir de aquí tu email será tu acceso a la competición.\n\n
      ¿Qué te recomendamos hacer hasta que comience el evento el 11 de mayo?\n
      - Sigue las novedades del evento en el Instagram de salva.pizzalover\n
      - Únete al canal de Pizzathon de su Instagram para no perderte nada\n
      - El acceso a la plataforma del evento se abrirá justo cuando se inicie Pizzathon\n- Prepárate y entrena para brillar en Pizzathon al mejor nivel\n\n
      Bienvenid@ a Pizzathon!`,
      html: `
        <p>Hola <b>${nombreUsuario}</b>,</p>
        <p>Tu inscripción a Pizzathon ha sido aceptada y a partir de aquí tu email será tu acceso a la competición.</p>
        <p>¿Qué te recomendamos hacer hasta que comience el evento el 11 de mayo?</p>
        <ul>
          <li>Sigue las novedades del evento en el Instagram de salva.pizzalover</li>
          <li>Únete al canal de Pizzathon de su Instagram para no perderte nada</li>
          <li>El acceso a la plataforma del evento se abrirá justo cuando se inicie Pizzathon</li>
          <li>Prepárate y entrena para brillar en Pizzathon al mejor nivel</li>
        </ul>
        <p>Bienvenid@ a Pizzathon!</p>
      `,
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
