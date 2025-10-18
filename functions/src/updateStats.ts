import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Cloud Function to update stats/main document
 * Triggers on writes to users, products, and orders collections
 * Aggregates counts and weekly order data
 */

const db = admin.firestore();
const STATS_DOC_PATH = 'stats/main';

/**
 * Helper to safely convert Firestore Timestamp or Date to Date
 */
function toDate(value: any): Date {
  if (value instanceof admin.firestore.Timestamp) {
    return value.toDate();
  }
  if (value instanceof Date) {
    return value;
  }
  if (typeof value === 'string') {
    return new Date(value);
  }
  return new Date();
}

/**
 * Aggregate all stats and update stats/main document
 */
async function aggregateStats(): Promise<void> {
  try {
    // Count users
    const usersSnapshot = await db.collection('users').count().get();
    const usersCount = usersSnapshot.data().count || 0;

    // Count products
    const productsSnapshot = await db.collection('products').count().get();
    const productsCount = productsSnapshot.data().count || 0;

    // Count low stock products (stock <= 5 and active)
    const lowStockSnapshot = await db
      .collection('products')
      .where('stock', '<=', 5)
      .where('isActive', '==', true)
      .count()
      .get();
    const lowStockCount = lowStockSnapshot.data().count || 0;

    // Count pending orders
    const pendingOrdersSnapshot = await db
      .collection('orders')
      .where('status', '==', 'pending')
      .count()
      .get();
    const pendingOrdersCount = pendingOrdersSnapshot.data().count || 0;

    // Get weekly orders (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const weeklyOrdersSnapshot = await db
      .collection('orders')
      .where('createdAt', '>=', admin.firestore.Timestamp.fromDate(sevenDaysAgo))
      .orderBy('createdAt', 'asc')
      .get();

    // Group orders by day
    const dailyTotals: { [key: string]: number } = {};
    weeklyOrdersSnapshot.docs.forEach((doc) => {
      const data = doc.data();
      const createdAt = toDate(data.createdAt);
      const dateKey = createdAt.toISOString().split('T')[0]; // YYYY-MM-DD

      // Safe total extraction
      let total = 0;
      if (typeof data.total === 'number') {
        total = data.total;
      } else if (data.total) {
        total = parseFloat(data.total.toString()) || 0;
      }

      dailyTotals[dateKey] = (dailyTotals[dateKey] || 0) + total;
    });

    // Create weeklyOrders array [day0, day1, ..., day6]
    const weeklyOrders: number[] = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateKey = date.toISOString().split('T')[0];
      weeklyOrders.push(dailyTotals[dateKey] || 0);
    }

    // Update stats/main document atomically
    await db.doc(STATS_DOC_PATH).set(
      {
        totalUsers: usersCount,
        totalProducts: productsCount,
        lowStockProducts: lowStockCount,
        pendingRedemptions: pendingOrdersCount, // Using same field name as dashboard
        usersCount,
        productsCount,
        lowStockCount,
        pendingOrdersCount,
        weeklyOrders,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    console.log('✅ Stats updated successfully:', {
      usersCount,
      productsCount,
      lowStockCount,
      pendingOrdersCount,
      weeklyOrdersLength: weeklyOrders.length,
    });
  } catch (error) {
    console.error('❌ Error updating stats:', error);
    throw error;
  }
}

/**
 * Trigger on user document writes
 */
export const onUserWrite = functions
  .region('us-central1')
  .firestore.document('users/{userId}')
  .onWrite(async (change, context) => {
    console.log('🔔 User write detected:', context.params.userId);
    await aggregateStats();
  });

/**
 * Trigger on product document writes
 */
export const onProductWrite = functions
  .region('us-central1')
  .firestore.document('products/{productId}')
  .onWrite(async (change, context) => {
    console.log('🔔 Product write detected:', context.params.productId);
    await aggregateStats();
  });

/**
 * Trigger on order document writes
 */
export const onOrderWrite = functions
  .region('us-central1')
  .firestore.document('orders/{orderId}')
  .onWrite(async (change, context) => {
    console.log('🔔 Order write detected:', context.params.orderId);
    await aggregateStats();
  });

/**
 * Manual trigger function (callable)
 * Can be called from admin panel to force stats update
 */
export const manualUpdateStats = functions
  .region('us-central1')
  .https.onCall(async (data, context) => {
    // Check if user is admin
    if (!context.auth || !context.auth.token.role || context.auth.token.role !== 'admin') {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Only admins can manually update stats'
      );
    }

    console.log('🔔 Manual stats update triggered by:', context.auth.uid);
    await aggregateStats();

    return { success: true, message: 'Stats updated successfully' };
  });

