import {onSchedule} from "firebase-functions/v2/scheduler";
import {getFirestore} from "firebase-admin/firestore";
import {getDatabase} from "firebase-admin/database";
import * as logger from "firebase-functions/logger";

export const updateScoreboard = onSchedule("*/30 * * * *", async (event) => {
  const db = getFirestore();
  const rtdb = getDatabase();
  const userCollectionName = "users_2026_05";

  try {
    logger.info("Starting scoreboard update...");

    // 1. Get all users with a score > 0, ordered by score
    const usersSnapshot = await db.collection(userCollectionName)
      .where("score", ">", 0)
      .orderBy("score", "desc")
      .get();

    const topUsers: any[] = [];
    const positions: {[key: string]: number} = {};

    let rank = 1;
    usersSnapshot.forEach((doc) => {
      const data = doc.data();
      const userId = doc.id;

      // Add to top list (limit to 100 for global ranking)
      if (rank <= 100) {
        topUsers.push({
          uid: userId,
          displayName: data.displayName || "Anonymous",
          photoUrl: data.photoUrl || "",
          score: data.score || 0,
          rank: rank,
        });
      }

      // Add to positions map (all users)
      positions[userId] = rank;
      rank++;
    });

    // 2. Atomic update in RTDB
    await rtdb.ref("scoreboard").update({
      top: topUsers,
      positions: positions,
      lastUpdated: new Date().toISOString(),
    });

    logger.info(`Scoreboard updated successfully. Processed ${usersSnapshot.size} users.`);
  } catch (error) {
    logger.error("Error updating scoreboard:", error);
  }
});
