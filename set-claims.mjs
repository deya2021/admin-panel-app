// set-claims.mjs
import { initializeApp, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import fs from "fs";

const serviceAccount = JSON.parse(fs.readFileSync("./serviceAccountKey.json", "utf8"));
initializeApp({ credential: cert(serviceAccount) });

const uid = "58HWFcPGTET0RgnIrJxhLaAsePC3"; // مثال: "7AFgRzWxyz..."
const role = "admin"; // أو "manager" إن أردت

getAuth()
    .setCustomUserClaims(uid, { role })
    .then(() => {
        console.log(`✅ تم تعيين role=${role} للمستخدم ${uid}`);
        process.exit(0);
    })
    .catch((err) => {
        console.error("❌ خطأ:", err);
        process.exit(1);
    });
