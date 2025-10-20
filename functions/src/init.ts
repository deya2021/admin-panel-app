import * as admin from "firebase-admin";

// احمِ نفسك من إعادة التهيئة عندما تعيد الديبلوير أو في ساخن/بارد
if (admin.apps.length === 0) {
    admin.initializeApp();
}

export { admin };
