import { admin } from "../init";
import type { Request, Response } from "express";

export interface AuthenticatedRequest extends Request {
  auth?: {
    uid: string;
    token: admin.auth.DecodedIdToken;
  };
}

/**
 * Middleware to verify Firebase ID token and ensure admin role
 */
export async function requireAdmin(
  req: AuthenticatedRequest,
  res: Response,
  next: () => void | Promise<void>
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      res.status(401).json({ error: "Unauthorized: Missing token" });
      return;
    }

    const token = authHeader.split("Bearer ")[1];
    const decodedToken = await admin.auth().verifyIdToken(token);

    if (decodedToken.role !== "admin") {
      res.status(403).json({ error: "Forbidden: Admin role required" });
      return;
    }

    req.auth = {
      uid: decodedToken.uid,
      token: decodedToken,
    };
    await next();
  } catch (error) {
    res.status(401).json({ error: "Unauthorized: Invalid token" });
  }
}
