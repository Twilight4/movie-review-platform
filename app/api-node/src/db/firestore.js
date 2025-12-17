const admin = require("firebase-admin");

/**
 * Configuration from environment variables (ConfigMap + Secret)
 */
const FIRESTORE_PROJECT_ID = process.env.FIRESTORE_PROJECT_ID;
const FIRESTORE_COLLECTION = process.env.FIRESTORE_COLLECTION || "movies";

/**
 * Fail fast if misconfigured
 */
if (!FIRESTORE_PROJECT_ID) {
  throw new Error("Missing FIRESTORE_PROJECT_ID");
}

let db = null;
let collection = null;

/**
 * Initialize Firestore connection
 * (lazy, singleton, container-friendly)
 */
function initFirestore() {
  if (db && collection) return { db, collection };

  console.log("🔌 Connecting to Firestore...");

  if (!admin.apps.length) {
    admin.initializeApp({
      projectId: FIRESTORE_PROJECT_ID,
      credential: admin.credential.applicationDefault(),
    });
  }

  db = admin.firestore();
  collection = db.collection(FIRESTORE_COLLECTION);

  console.log("✅ Firestore initialized:", {
    project: FIRESTORE_PROJECT_ID,
    collection: FIRESTORE_COLLECTION,
  });

  return { db, collection };
}

/**
 * Create document
 */
async function createItem(item) {
  initFirestore();
  const docRef = await collection.add(item);
  return { id: docRef.id, ...item };
}

/**
 * Get document by ID
 */
async function getItem(id) {
  initFirestore();
  const doc = await collection.doc(id).get();
  return doc.exists ? { id: doc.id, ...doc.data() } : null;
}

/**
 * Query documents
 */
async function queryItems(field, operator, value) {
  initFirestore();
  const snapshot = await collection.where(field, operator, value).get();
  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));
}

/**
 * Update document (replace semantics)
 */
async function updateItem(id, newData) {
  initFirestore();
  await collection.doc(id).set(newData, { merge: false });
  return { id, ...newData };
}

/**
 * Delete document
 */
async function deleteItem(id) {
  initFirestore();
  await collection.doc(id).delete();
  return true;
}

module.exports = {
  initFirestore,
  createItem,
  getItem,
  queryItems,
  updateItem,
  deleteItem,
};
