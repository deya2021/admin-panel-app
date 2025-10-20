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
exports.processRedemption = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
/**
 * Callable Cloud Function to process redemption requests
 * Only admins and managers can call this function
 * Handles both approval and rejection of redemption requests
 */
const db = admin.firestore();
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
exports.processRedemption = functions
    .region('us-central1')
    .https.onCall(async (data, context) => {
    // Check authentication
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'المستخدم غير مصادق عليه' // User not authenticated
        );
    }
    // Check authorization (admin or manager only)
    const role = context.auth.token.role;
    if (role !== 'admin' && role !== 'manager') {
        throw new functions.https.HttpsError('permission-denied', 'هذه العملية متاحة للمديرين فقط' // This operation is only available to admins/managers
        );
    }
    // Validate input
    const { redemptionId, action } = data;
    if (!redemptionId || typeof redemptionId !== 'string') {
        throw new functions.https.HttpsError('invalid-argument', 'معرف الاسترداد غير صحيح' // Invalid redemption ID
        );
    }
    if (action !== 'approve' && action !== 'reject') {
        throw new functions.https.HttpsError('invalid-argument', 'الإجراء غير صحيح' // Invalid action
        );
    }
    console.log(`🔔 Processing redemption ${redemptionId} - Action: ${action} by ${context.auth.uid}`);
    try {
        const redemptionRef = db.collection('redemptions').doc(redemptionId);
        // Run in transaction for atomicity
        const result = await db.runTransaction(async (transaction) => {
            // Get redemption document
            const redemptionDoc = await transaction.get(redemptionRef);
            if (!redemptionDoc.exists) {
                throw new functions.https.HttpsError('not-found', 'طلب الاسترداد غير موجود' // Redemption request not found
                );
            }
            const redemptionData = redemptionDoc.data();
            const currentStatus = redemptionData.status || '';
            // Check if already processed
            if (currentStatus !== 'pending') {
                throw new functions.https.HttpsError('failed-precondition', `طلب الاسترداد تمت معالجته بالفعل (${currentStatus})` // Redemption already processed
                );
            }
            const userId = redemptionData.userId || '';
            const points = toNumber(redemptionData.points);
            if (!userId) {
                throw new functions.https.HttpsError('invalid-argument', 'معرف المستخدم غير موجود في طلب الاسترداد' // User ID not found in redemption
                );
            }
            if (points <= 0) {
                throw new functions.https.HttpsError('invalid-argument', 'عدد النقاط غير صحيح' // Invalid points amount
                );
            }
            // Handle rejection (simple status update)
            if (action === 'reject') {
                transaction.update(redemptionRef, {
                    status: 'rejected',
                    rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
                    rejectedBy: context.auth.uid,
                });
                console.log(`✅ Redemption ${redemptionId} rejected successfully`);
                return {
                    success: true,
                    message: 'تم رفض طلب الاسترداد', // Redemption request rejected
                    action: 'reject',
                };
            }
            // Handle approval (deduct points and create ledger entry)
            const userRef = db.collection('users').doc(userId);
            const userDoc = await transaction.get(userRef);
            if (!userDoc.exists) {
                throw new functions.https.HttpsError('not-found', 'المستخدم غير موجود' // User not found
                );
            }
            const userData = userDoc.data();
            const currentPoints = toNumber(userData.totalPoints);
            // Check if user has enough points
            if (currentPoints < points) {
                throw new functions.https.HttpsError('failed-precondition', `رصيد النقاط غير كافٍ (${currentPoints} < ${points})` // Insufficient points balance
                );
            }
            // Use deterministic ledger doc ID for idempotency
            const ledgerDocId = `redemption_${redemptionId}`;
            const ledgerRef = db
                .collection('users')
                .doc(userId)
                .collection('points_ledger')
                .doc(ledgerDocId);
            // Check if ledger entry already exists
            const ledgerDoc = await transaction.get(ledgerRef);
            if (ledgerDoc.exists) {
                console.log(`⚠️  Ledger entry already exists for redemption ${redemptionId}`);
                // Update redemption status anyway to ensure consistency
                transaction.update(redemptionRef, {
                    status: 'approved',
                    approvedAt: admin.firestore.FieldValue.serverTimestamp(),
                    approvedBy: context.auth.uid,
                });
                return {
                    success: true,
                    message: 'طلب الاسترداد تمت الموافقة عليه بالفعل', // Redemption already approved
                    action: 'approve',
                };
            }
            // Create ledger entry (negative points for redemption)
            transaction.set(ledgerRef, {
                userId,
                points: -points, // Negative for redemption
                type: 'redeemed',
                source: 'redemption',
                redemptionId,
                description: redemptionData.description || '',
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Deduct points from user
            transaction.update(userRef, {
                totalPoints: currentPoints - points,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Update redemption status
            transaction.update(redemptionRef, {
                status: 'approved',
                approvedAt: admin.firestore.FieldValue.serverTimestamp(),
                approvedBy: context.auth.uid,
            });
            console.log(`✅ Redemption ${redemptionId} approved: ${points} points deducted from user ${userId}`);
            return {
                success: true,
                message: 'تمت الموافقة على طلب الاسترداد', // Redemption request approved
                action: 'approve',
                pointsDeducted: points,
                newBalance: currentPoints - points,
            };
        });
        return result;
    }
    catch (error) {
        console.error(`❌ Error processing redemption ${redemptionId}:`, error);
        // Re-throw HttpsError as-is
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        // Wrap other errors
        throw new functions.https.HttpsError('internal', 'فشلت معالجة طلب الاسترداد', // Failed to process redemption request
        error.message);
    }
});
//# sourceMappingURL=processRedemption.js.map