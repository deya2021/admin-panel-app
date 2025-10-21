import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const STATS_DOC = db.collection('stats').doc('main');
const LOW_STOCK_THRESHOLD = 10;

function toDate(v: any): Date | null {
  if (!v) return null;
  if (v instanceof Date) return v;
  if (typeof v?.toDate === 'function') return v.toDate();
  const d = new Date(v);
  return isNaN(d.getTime()) ? null : d;
}

/**
 * Compute weekly orders for the last 7 days
 * Returns array of 7 integers [oldest...newest] where index 6 is today
 */
async function computeWeeklyOrders(): Promise<number[]> {
  const now = new Date();
  const today0 = new Date(now);
  today0.setHours(0, 0, 0, 0);
  
  // Start from 6 days ago (7 days including today)
  const windowStart = new Date(today0);
  windowStart.setDate(windowStart.getDate() - 6);

  const snap = await db.collection('orders')
    .where('createdAt', '>=', windowStart)
    .get();
  
  // Initialize 7 buckets (all zeros)
  const buckets: number[] = [0, 0, 0, 0, 0, 0, 0];

  snap.forEach(doc => {
    const d = toDate(doc.get('createdAt'));
    if (!d) return;
    
    const day0 = new Date(d);
    day0.setHours(0, 0, 0, 0);
    
    // Calculate days difference from today
    const diffMs = today0.getTime() - day0.getTime();
    const diffDays = Math.round(diffMs / 86400000);
    
    // Map to index: 0 = oldest (6 days ago), 6 = today
    const idx = 6 - diffDays;
    
    if (idx >= 0 && idx < 7) {
      buckets[idx] += 1;
    }
  });

  // Ensure we always return exactly 7 integers
  return buckets;
}

async function aggregateStats(): Promise<void> {
  const usersCount = (await db.collection('users').count().get()).data().count || 0;

  const productsCount = (await db.collection('products').count().get()).data().count || 0;

  const lowStockCount = (await db.collection('products')
    .where('stock', '<=', LOW_STOCK_THRESHOLD)
    .where('isActive', '==', true)
    .count().get()).data().count || 0;

  const pendingOrdersCount = (await db.collection('orders')
    .where('status', '==', 'pending')
    .count().get()).data().count || 0;

  const weeklyOrders = await computeWeeklyOrders();

  await STATS_DOC.set({
    usersCount,
    productsCount,
    lowStockCount,
    pendingOrdersCount,
    weeklyOrders,
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
}

// Firestore triggers for automatic stats updates
export const statsOnUserWrite = functions.firestore
  .document('users/{id}')
  .onWrite(async () => { await aggregateStats(); });

export const statsOnProductWrite = functions.firestore
  .document('products/{id}')
  .onWrite(async () => { await aggregateStats(); });

export const statsOnOrderWrite = functions.firestore
  .document('orders/{id}')
  .onWrite(async () => { await aggregateStats(); });

/**
 * Manually recalculate weekly orders on demand
 * Callable by admins to refresh weekly statistics
 */
export const recalcWeekly = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'المستخدم غير مصادق عليه'
    );
  }

  // Check if caller is admin
  const callerToken = context.auth.token;
  if (callerToken.role !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'هذه العملية متاحة للمديرين فقط'
    );
  }

  try {
    const weeklyOrders = await computeWeeklyOrders();

    await STATS_DOC.set({
      weeklyOrders,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    functions.logger.info('Weekly orders recalculated successfully');

    return {
      success: true,
      weeklyOrders,
      message: 'تم إعادة حساب الطلبات الأسبوعية بنجاح',
    };
  } catch (error: any) {
    functions.logger.error('Error recalculating weekly orders:', error);
    throw new functions.https.HttpsError(
      'internal',
      'فشل إعادة حساب الطلبات الأسبوعية',
      error.message
    );
  }
});
