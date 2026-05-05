/* eslint-disable */

import * as logger from "firebase-functions/logger";
import { onDocumentUpdated } from "firebase-functions/firestore";
import { getFirestore } from "firebase-admin/firestore";
import { transporter, FROM_ADDRESS } from "./mailer";

const pizzaCollection = "pizzas_2026_05";
const userCollection = "users_2026_05";

const pizzaStyleDisplayNames: Record<string, string> = {
  contemporanea: "Contemporánea",
  napoletana: "Napoletana",
  newYork: "New York",
  tondaClasica: "Tonda clásica",
  tondaRomana: "Tonda romana",
  tegliaRomana: "Teglia romana",
  padellino: "Padellino",
  palaRomana: "Pala romana",
};

export const onPizzaReviewed = onDocumentUpdated(
  `${pizzaCollection}/{pizzaId}`,
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return null;

    // Solo actuar si el status ha cambiado
    if (before.status === after.status) {
      return null;
    }

    // Solo actuar si el nuevo status es approved o rejected
    if (after.status !== "approved" && after.status !== "rejected") {
      return null;
    }

    const userId = after.userId;
    if (!userId) {
      logger.warn(`Pizza ${event.params.pizzaId} no tiene userId.`);
      return null;
    }

    // Obtener datos del usuario (1 lectura Firestore)
    const userDoc = await getFirestore().collection(userCollection).doc(userId).get();
    const userData = userDoc.data();

    if (!userData || !userData.email) {
      logger.warn(`Usuario ${userId} no encontrado o no tiene email.`);
      return null;
    }

    const emailDestino = userData.email;
    const nombreUsuario = userData.displayName || "usuario";
    const statusLabel = after.status === "approved" ? "APROBADA" : "RECHAZADA";
    const pizzaStyle = pizzaStyleDisplayNames[after.pizzaStyle] || after.pizzaStyle || "Pizza";
    const fecha = after.createdAt ? new Date(after.createdAt.toDate()).toLocaleDateString("es-ES") : "";
    const adminComment = after.adminComment;

    const subject = `Tu pizza ha sido ${after.status === "approved" ? "aprobada" : "revisada"} - Pizzathon`;
    
    let text = `Hola ${nombreUsuario},\n\nTu pizza de estilo ${pizzaStyle} del día ${fecha} ha sido ${statusLabel}.\n\n`;
    let html = `<p>Hola <b>${nombreUsuario}</b>,</p><p>Tu pizza de estilo <b>${pizzaStyle}</b> del día ${fecha} ha sido <b>${statusLabel}</b>.</p>`;

    if (adminComment && adminComment.trim().length > 0) {
      text += `Comentario del administrador: ${adminComment}\n\n`;
      html += `<p><b>Comentario del administrador:</b><br/>${adminComment}</p>`;
    }

    text += "¡Gracias por participar en Pizzathon!";
    html += "<p>¡Gracias por participar en Pizzathon!</p>";

    const mailOptions = {
      from: FROM_ADDRESS,
      to: emailDestino,
      subject: subject,
      text: text,
      html: html,
    };

    try {
      await transporter.sendMail(mailOptions);
      logger.info(`Email de revisión enviado a ${emailDestino} para la pizza ${event.params.pizzaId}`);
    } catch (error) {
      logger.error("Fallo al enviar el email de revisión:", error);
    }

    return null;
  }
);
