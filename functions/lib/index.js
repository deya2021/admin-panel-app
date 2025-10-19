"use strict";
/**
 * Cloud Functions for Admin Panel
 *
 * Deploy with: firebase deploy --only functions
 */
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
exports.statsOnOrderWrite = exports.statsOnProductWrite = exports.statsOnUserWrite = exports.recalculateStats = exports.onProductWrite = exports.onOrderCreated = exports.checkLowStock = exports.onRedemptionStatusChange = exports.onNewRedemption = exports.initializeUserRole = exports.setUserRole = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
// Initialize Firebase Admin
admin.initializeApp();
// ============================================================================
// AUTH FUNCTIONS
// ============================================================================
/**
 * Set user role via custom claims
 * Only callable by admins
 */
exports.setUserRole = functions.https.onCall(async (data, context) => {
    // Check authentication
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'المستخدم غير مصادق عليه' // User not authenticated
        );
    }
    // Check if caller is admin
    const callerToken = context.auth.token;
    if (callerToken.role !== 'admin') {
        throw new functions.https.HttpsError('permission-denied', 'هذه العملية متاحة للمديرين فقط' // This operation is only available to admins
        );
    }
    const { userId, role } = data;
    // Validate inputs
    if (!userId || typeof userId !== 'string') {
        throw new functions.https.HttpsError('invalid-argument', 'معرف المستخدم غير صحيح' // Invalid user ID
        );
    }
    const validRoles = ['admin', 'manager', 'user'];
    if (!role || !validRoles.includes(role)) {
        throw new functions.https.HttpsError('invalid-argument', 'الدور يجب أن يكون: admin أو manager أو user' // Role must be: admin, manager, or user
        );
    }
    try {
        // Set custom claims
        await admin.auth().setCustomUserClaims(userId, { role });
        // Update user document in Firestore
        await admin.firestore().collection('users').doc(userId).update({
            role: role,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        functions.logger.info(`Role set for user ${userId}: ${role}`);
        return {
            success: true,
            message: `تم تعيين الدور إلى ${role}`, // Role set to X
        };
    }
    catch (error) {
        functions.logger.error('Error setting user role:', error);
        throw new functions.https.HttpsError('internal', 'فشل تعيين الدور', // Failed to set role
        error.message);
    }
});
/**
 * Initialize user role on account creation
 * Sets default role to 'user'
 */
exports.initializeUserRole = functions.auth.user().onCreate(async (user) => {
    try {
        // Set default role to 'user'
        await admin.auth().setCustomUserClaims(user.uid, { role: 'user' });
        // Create user document
        await admin.firestore().collection('users').doc(user.uid).set({
            uid: user.uid,
            email: user.email || null,
            phoneNumber: user.phoneNumber || null,
            displayName: user.displayName || null,
            role: 'user',
            totalPoints: 0,
            redeemedPoints: 0,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        functions.logger.info(`User initialized: ${user.uid} with role: user`);
    }
    catch (error) {
        functions.logger.error('Error initializing user:', error);
    }
});
// ============================================================================
// NOTIFICATION FUNCTIONS
// ============================================================================
/**
 * Send notification to admins/managers when a new redemption is created
 */
exports.onNewRedemption = functions.firestore
    .document('redemptions/{redemptionId}')
    .onCreate(async (snap, context) => {
    const redemption = snap.data();
    const redemptionId = context.params.redemptionId;
    try {
        // Get user details
        const userDoc = await admin.firestore().collection('users').doc(redemption.uid).get();
        const userData = userDoc.data();
        // Prepare notification
        const message = {
            notification: {
                title: 'طلب استبدال جديد', // New redemption request
                body: `${(userData === null || userData === void 0 ? void 0 : userData.displayName) || 'مستخدم'} طلب استبدال ${redemption.points} نقطة`, // User requested redemption of X points
            },
            data: {
                type: 'new_redemption',
                redemptionId: redemptionId,
                userId: redemption.uid,
                points: redemption.points.toString(),
            },
            topic: 'admin_alerts',
        };
        // Send notification
        await admin.messaging().send(message);
        functions.logger.info(`Notification sent for new redemption: ${redemptionId}`);
    }
    catch (error) {
        functions.logger.error('Error sending new redemption notification:', error);
    }
});
/**
 * Send notification to user when redemption status changes
 */
exports.onRedemptionStatusChange = functions.firestore
    .document('redemptions/{redemptionId}')
    .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    // Check if status changed
    if (before.status === after.status) {
        return;
    }
    try {
        // Get user's FCM token
        const userDoc = await admin.firestore().collection('users').doc(after.uid).get();
        const userData = userDoc.data();
        if (!(userData === null || userData === void 0 ? void 0 : userData.fcmToken)) {
            functions.logger.warn(`No FCM token for user: ${after.uid}`);
            return;
        }
        // Prepare notification based on status
        let title = '';
        let body = '';
        switch (after.status) {
            case 'approved':
                title = 'تمت الموافقة على الاستبدال'; // Redemption approved
                body = `تمت الموافقة على طلب استبدال ${after.points} نقطة`; // Your redemption request of X points has been approved
                break;
            case 'rejected':
                title = 'تم رفض الاستبدال'; // Redemption rejected
                body = `تم رفض طلب استبدال ${after.points} نقطة`; // Your redemption request of X points has been rejected
                break;
            case 'completed':
                title = 'اكتمل الاستبدال'; // Redemption completed
                body = `تم إكمال استبدال ${after.points} نقطة`; // Redemption of X points has been completed
                break;
            default:
                return;
        }
        const message = {
            notification: { title, body },
            data: {
                type: 'redemption_status_update',
                redemptionId: context.params.redemptionId,
                status: after.status,
                points: after.points.toString(),
            },
            token: userData.fcmToken,
        };
        // Send notification
        await admin.messaging().send(message);
        functions.logger.info(`Status update notification sent for redemption: ${context.params.redemptionId}`);
    }
    catch (error) {
        functions.logger.error('Error sending redemption status notification:', error);
    }
});
/**
 * Check for low stock products and notify admins/managers
 * Scheduled to run daily at 9 AM
 */
exports.checkLowStock = functions.pubsub
    .schedule('0 9 * * *') // Every day at 9 AM
    .timeZone('UTC')
    .onRun(async (context) => {
    try {
        // Get all active products
        const productsSnapshot = await admin.firestore()
            .collection('products')
            .where('isActive', '==', true)
            .get();
        const lowStockProducts = [];
        productsSnapshot.forEach((doc) => {
            const product = doc.data();
            const stockLevel = product.stockQty || 0;
            const threshold = product.lowStockThreshold || 5;
            if (stockLevel > 0 && stockLevel <= threshold) {
                lowStockProducts.push({
                    id: doc.id,
                    title: product.title,
                    stockQty: stockLevel,
                    threshold: threshold,
                });
            }
        });
        // If there are low stock products, send notification
        if (lowStockProducts.length > 0) {
            const productNames = lowStockProducts.map(p => p.title).join('، ');
            const message = {
                notification: {
                    title: 'تنبيه: مخزون منخفض', // Alert: Low stock
                    body: `${lowStockProducts.length} منتج لديه مخزون منخفض: ${productNames}`, // X products have low stock
                },
                data: {
                    type: 'low_stock',
                    productCount: lowStockProducts.length.toString(),
                    products: JSON.stringify(lowStockProducts),
                },
                topic: 'admin_alerts',
            };
            await admin.messaging().send(message);
            functions.logger.info(`Low stock notification sent for ${lowStockProducts.length} products`);
        }
        else {
            functions.logger.info('No low stock products found');
        }
    }
    catch (error) {
        functions.logger.error('Error checking low stock:', error);
    }
});
// ============================================================================
// STATS UPDATE FUNCTIONS
// ============================================================================
/**
 * Update stats when a new order is created
 */
exports.onOrderCreated = functions.firestore
    .document('orders/{orderId}')
    .onCreate(async (snap, context) => {
    const statsRef = admin.firestore().collection('stats').doc('main');
    try {
        await statsRef.set({
            totalOrders: admin.firestore.FieldValue.increment(1),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        functions.logger.info('Stats updated: order created');
    }
    catch (error) {
        functions.logger.error('Error updating stats on order:', error);
    }
});
/**
 * Update stats when a product is created/updated/deleted
 */
exports.onProductWrite = functions.firestore
    .document('products/{productId}')
    .onWrite(async (change, context) => {
    const statsRef = admin.firestore().collection('stats').doc('main');
    try {
        // Count all products and active products
        const productsSnapshot = await admin.firestore().collection('products').get();
        const totalProducts = productsSnapshot.size;
        const activeProducts = productsSnapshot.docs.filter(doc => doc.data().isActive === true).length;
        await statsRef.set({
            totalProducts,
            activeProducts,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        functions.logger.info('Stats updated: product changed');
    }
    catch (error) {
        functions.logger.error('Error updating stats on product:', error);
    }
});
/**
 * Recalculate all stats (callable by admins)
 */
exports.recalculateStats = functions.https.onCall(async (data, context) => {
    // Check if caller is admin
    if (!context.auth || context.auth.token.role !== 'admin') {
        throw new functions.https.HttpsError('permission-denied', 'هذه العملية متاحة للمديرين فقط' // This operation is only available to admins
        );
    }
    try {
        const db = admin.firestore();
        // Count users
        const usersSnapshot = await db.collection('users').count().get();
        const totalUsers = usersSnapshot.data().count;
        // Count orders
        const ordersSnapshot = await db.collection('orders').count().get();
        const totalOrders = ordersSnapshot.data().count;
        // Count products
        const productsSnapshot = await db.collection('products').get();
        const totalProducts = productsSnapshot.size;
        const activeProducts = productsSnapshot.docs.filter(doc => doc.data().isActive === true).length;
        // Count pending redemptions
        const pendingRedemptionsSnapshot = await db.collection('redemptions')
            .where('status', '==', 'pending')
            .count()
            .get();
        const pendingRedemptions = pendingRedemptionsSnapshot.data().count;
        // Update stats document
        await db.collection('stats').doc('main').set({
            totalUsers,
            totalOrders,
            totalProducts,
            activeProducts,
            pendingRedemptions,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
        functions.logger.info('All stats recalculated successfully');
        return {
            success: true,
            stats: {
                totalUsers,
                totalOrders,
                totalProducts,
                activeProducts,
                pendingRedemptions,
            },
        };
    }
    catch (error) {
        functions.logger.error('Error recalculating stats:', error);
        throw new functions.https.HttpsError('internal', 'فشل إعادة حساب الإحصائيات', // Failed to recalculate stats
        error.message);
    }
});
// ============================================================================
// STATS UPDATE FUNCTIONS
// ============================================================================
var updateStats_1 = require("./updateStats");
Object.defineProperty(exports, "statsOnUserWrite", { enumerable: true, get: function () { return updateStats_1.statsOnUserWrite; } });
Object.defineProperty(exports, "statsOnProductWrite", { enumerable: true, get: function () { return updateStats_1.statsOnProductWrite; } });
Object.defineProperty(exports, "statsOnOrderWrite", { enumerable: true, get: function () { return updateStats_1.statsOnOrderWrite; } });
//# sourceMappingURL=index.js.map