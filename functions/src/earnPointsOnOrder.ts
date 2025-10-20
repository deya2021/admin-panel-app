import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Cloud Function to award points when order is delivered
 * Triggers on orders/{orderId} writes
 * Awards points based on order total (1% by default)
 */

const db = admin.firestore();

// Configuration
const EARNING_RATE = 0.02; // 2% of order total

/**
 * Helper to safely convert Firestore Timestamp or Date to Date
 */


/**
 * Helper to safely extract number from various types
 */
function toNumber(value: any): number {
  if (typeof value === 'number') {
    return value;
  }
  if (typeof value === 'string') {
    return parseFloat(value) || 0;
  }
  return 0;
}

/**
 * Award points to user for delivered order
 * Idempotent: uses deterministic ledger doc ID to prevent duplicate awards
 */
export const earnPointsOnOrder = functions
  .region('us-central1')
  .firestore.document('orders/{orderId}')
  .onWrite(async (change, context) => {
    const orderId = context.params.orderId;

    // Skip if document was deleted
    if (!change.after.exists) {
      console.log(`⏭️  Order ${orderId} deleted, skipping`);
      return;
    }

    const beforeData = change.before.exists ? change.before.data() : null;
    const afterData = change.after.data();

    if (!afterData) {
      console.log(`⏭️  Order ${orderId} has no data, skipping`);
      return;
    }

    // Check if status changed to "completed"
    const beforeStatus = beforeData?.status || '';
    const afterStatus = afterData.status || '';

    if (afterStatus !== 'completed') {
      console.log(`⏭️  Order ${orderId} status is "${afterStatus}", not "completed", skipping`);
      return;
    }

    if (beforeStatus === 'completed') {
      console.log(`⏭️  Order ${orderId} was already "completed", skipping`);
      return;
    }

    console.log(`🎯 Order ${orderId} status changed to "completed", processing points...`);

    // Extract user ID (try userId or uid)
    const userId = afterData.userId || afterData.uid || '';
    if (!userId) {
      console.error(`❌ Order ${orderId} has no userId/uid, cannot award points`);
      return;
    }

    // Extract and validate total
    const total = toNumber(afterData.total);
    if (total <= 0) {
      console.log(`⏭️  Order ${orderId} has total ${total}, no points to award`);
      return;
    }

    // Calculate points (floor to ensure integer)
    const points = Math.floor(total * EARNING_RATE);
    if (points <= 0) {
      console.log(`⏭️  Order ${orderId} total ${total} results in 0 points, skipping`);
      return;
    }

    console.log(`💰 Awarding ${points} points to user ${userId} for order ${orderId} (total: ${total})`);

    try {
      // Use deterministic ledger doc ID for idempotency
      const ledgerDocId = `order_${orderId}`;
      const ledgerRef = db
        .collection('users')
        .doc(userId)
        .collection('points_ledger')
        .doc(ledgerDocId);

      const userRef = db.collection('users').doc(userId);

      // Run in transaction for atomicity
      await db.runTransaction(async (transaction) => {
        // Check if ledger entry already exists (idempotency)
        const ledgerDoc = await transaction.get(ledgerRef);
        if (ledgerDoc.exists) {
          console.log(`✅ Points already awarded for order ${orderId}, skipping`);
          return;
        }

        // Get user document
        const userDoc = await transaction.get(userRef);
        if (!userDoc.exists) {
          console.error(`❌ User ${userId} not found, cannot award points`);
          throw new Error(`User ${userId} not found`);
        }

        const userData = userDoc.data() || {};
        const currentPoints = toNumber(userData.totalPoints);

        // Create ledger entry
        transaction.set(ledgerRef, {
          userId,
          points,
          type: 'earned',
          source: 'order',
          orderId,
          amount: total,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update user's total points
        transaction.update(userRef, {
          totalPoints: currentPoints + points,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`✅ Successfully awarded ${points} points to user ${userId} for order ${orderId}`);
      });
    } catch (error: any) {
      console.error(`❌ Error awarding points for order ${orderId}:`, error);
      throw error;
    }
  });

