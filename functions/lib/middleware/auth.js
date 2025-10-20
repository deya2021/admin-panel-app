"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAdmin = requireAdmin;
const init_1 = require("../init");
/**
 * Middleware to verify Firebase ID token and ensure admin role
 */
async function requireAdmin(req, res, next) {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            res.status(401).json({ error: "Unauthorized: Missing token" });
            return;
        }
        const token = authHeader.split("Bearer ")[1];
        const decodedToken = await init_1.admin.auth().verifyIdToken(token);
        if (decodedToken.role !== "admin") {
            res.status(403).json({ error: "Forbidden: Admin role required" });
            return;
        }
        req.auth = {
            uid: decodedToken.uid,
            token: decodedToken,
        };
        await next();
    }
    catch (error) {
        res.status(401).json({ error: "Unauthorized: Invalid token" });
    }
}
//# sourceMappingURL=auth.js.map