"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.earnPointsOnOrder = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
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
function toNumber(value) {
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
exports.earnPointsOnOrder = functions
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
    const beforeStatus = (beforeData === null || beforeData === void 0 ? void 0 : beforeData.status) || '';
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
    }
    catch (error) {
        console.error(`❌ Error awarding points for order ${orderId}:`, error);
        throw error;
    }
});
//# sourceMappingURL=earnPointsOnOrder.js.map