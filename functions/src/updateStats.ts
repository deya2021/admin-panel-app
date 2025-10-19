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

async function computeWeeklyOrders(): Promise<number[]> {
  const now = new Date();
  const today0 = new Date(now); today0.setHours(0, 0, 0, 0);
  const windowStart = new Date(today0); windowStart.setDate(windowStart.getDate() - 6);

  const snap = await db.collection('orders').where('createdAt', '>=', windowStart).get();
  const buckets = Array(7).fill(0);

  snap.forEach(doc => {
    const d = toDate(doc.get('createdAt'));
    if (!d) return;
    const day0 = new Date(d); day0.setHours(0, 0, 0, 0);
    const diff = Math.round((today0.getTime() - day0.getTime()) / 86400000);
    const idx = 6 - diff; // 0 أقدم .. 6 اليوم
    if (idx >= 0 && idx < 7) buckets[idx] += 1;
  });

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

// أسماء مختلفة لتجنّب التصادم مع دوال موجودة في index.ts
export const statsOnUserWrite = functions.firestore
  .document('users/{id}')
  .onWrite(async () => { await aggregateStats(); });

export const statsOnProductWrite = functions.firestore
  .document('products/{id}')
  .onWrite(async () => { await aggregateStats(); });

export const statsOnOrderWrite = functions.firestore
  .document('orders/{id}')
  .onWrite(async () => { await aggregateStats(); });

