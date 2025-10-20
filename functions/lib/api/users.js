"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setRole = exports.updateUser = exports.createUser = void 0;
const init_1 = require("../init");
const https_1 = require("firebase-functions/v2/https");
const auth_1 = require("../middleware/auth");
const db = init_1.admin.firestore();
const auth = init_1.admin.auth();
/**
 * Create a new user with custom claims and Firestore document
 */
exports.createUser = (0, https_1.onRequest)({ region: "us-central1" }, async (req, res) => {
    await (0, auth_1.requireAdmin)(req, res, async () => {
        try {
            const { email, password, displayName, role } = req.body;
            if (!email || !password) {
                res.status(400).json({ error: "Email and password are required" });
                return;
            }
            // Create user in Firebase Auth
            const userRecord = await auth.createUser({
                email,
                password,
                displayName: displayName || "",
            });
            // Set custom claims
            const userRole = role || "user";
            await auth.setCustomUserClaims(userRecord.uid, { role: userRole });
            // Create Firestore document
            await db.collection("users").doc(userRecord.uid).set({
                email,
                displayName: displayName || "",
                role: userRole,
                totalPoints: 0,
                redeemedPoints: 0,
                createdAt: init_1.admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: init_1.admin.firestore.FieldValue.serverTimestamp(),
            });
            res.status(201).json({
                success: true,
                uid: userRecord.uid,
                email: userRecord.email,
                role: userRole,
            });
        }
        catch (error) {
            res.status(500).json({ error: error.message });
        }
    });
});
/**
 * Update user profile (displayName, disabled status)
 */
exports.updateUser = (0, https_1.onRequest)({ region: "us-central1" }, async (req, res) => {
    await (0, auth_1.requireAdmin)(req, res, async () => {
        try {
            const { uid, displayName, disabled } = req.body;
            if (!uid) {
                res.status(400).json({ error: "uid is required" });
                return;
            }
            const updates = {};
            if (displayName !== undefined)
                updates.displayName = displayName;
            if (disabled !== undefined)
                updates.disabled = disabled;
            // Update Firebase Auth
            await auth.updateUser(uid, updates);
            // Update Firestore
            const firestoreUpdates = {
                updatedAt: init_1.admin.firestore.FieldValue.serverTimestamp(),
            };
            if (displayName !== undefined) {
                firestoreUpdates.displayName = displayName;
            }
            await db.collection("users").doc(uid).update(firestoreUpdates);
            res.status(200).json({
                success: true,
                uid,
                updated: updates,
            });
        }
        catch (error) {
            res.status(500).json({ error: error.message });
        }
    });
});
/**
 * Set user role (updates custom claims + Firestore)
 */
exports.setRole = (0, https_1.onRequest)({ region: "us-central1" }, async (req, res) => {
    await (0, auth_1.requireAdmin)(req, res, async () => {
        try {
            const { uid, role } = req.body;
            if (!uid || !role) {
                res.status(400).json({ error: "uid and role are required" });
                return;
            }
            // Validate role
            const validRoles = ["admin", "manager", "user"];
            if (!validRoles.includes(role)) {
                res.status(400).json({
                    error: `Invalid role. Must be one of: ${validRoles.join(", ")}`,
                });
                return;
            }
            // Update custom claims
            await auth.setCustomUserClaims(uid, { role });
            // Update Firestore
            await db.collection("users").doc(uid).update({
                role,
                updatedAt: init_1.admin.firestore.FieldValue.serverTimestamp(),
            });
            res.status(200).json({
                success: true,
                uid,
                role,
            });
        }
        catch (error) {
            res.status(500).json({ error: error.message });
        }
    });
});
//# sourceMappingURL=users.js.map