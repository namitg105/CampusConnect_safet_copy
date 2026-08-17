/**
 * One-off migration for the Noteswap Firestore collections.
 *
 *   notes         -> noteswap_notes         (valid docs only + their /reviews)
 *   bought_notes  -> noteswap_bought_notes
 *
 * "Valid" means the doc has a non-empty `title` AND `fileUrl` string — the same
 * rule the app uses (_isValidNote). Placeholder/junk docs are skipped and
 * reported so you can review/delete them separately.
 *
 * Usage (run from repo root):
 *   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json
 *   node tools/migrate_noteswap_collections.js              # dry run
 *   node tools/migrate_noteswap_collections.js --apply      # copy data
 *   node tools/migrate_noteswap_collections.js --apply --delete-old
 *                                                            # copy, then delete old cols
 *
 * Requires: npm install firebase-admin
 */
'use strict';

const { initializeApp, cert, deleteApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const APPLY = process.argv.includes('--apply');
const DELETE_OLD = process.argv.includes('--delete-old');

const OLD = {
  notes: 'notes',
  boughtNotes: 'bought_notes',
};
const NEW = {
  notes: 'noteswap_notes',
  boughtNotes: 'noteswap_bought_notes',
};

function isValidNote(data) {
  const title = data.title;
  const fileUrl = data.fileUrl;
  return (
    typeof title === 'string' &&
    title.trim().length > 0 &&
    typeof fileUrl === 'string' &&
    fileUrl.trim().length > 0
  );
}

async function copyCollection(oldName, newName, { subcollections = [] } = {}) {
  const db = getFirestore();
  const oldCol = db.collection(oldName);
  const newCol = db.collection(newName);

  const snap = await oldCol.get();
  let copied = 0;
  let skipped = 0;

  for (const doc of snap.docs) {
    const data = doc.data();

    if (oldName === OLD.notes && !isValidNote(data)) {
      skipped++;
      console.log(
        `  skip  ${oldName}/${doc.id}  (missing title/fileUrl - junk)`
      );
      continue;
    }

    if (!APPLY) {
      copied++;
      continue;
    }

    await newCol.doc(doc.id).set(data, { merge: true });

    for (const sub of subcollections) {
      const subSnap = await oldCol.doc(doc.id).collection(sub).get();
      if (subSnap.size === 0) continue;
      let batch = db.batch();
      let inBatch = 0;
      for (const subDoc of subSnap.docs) {
        batch.set(newCol.doc(doc.id).collection(sub).doc(subDoc.id), subDoc.data());
        inBatch++;
        if (inBatch === 400) {
          await batch.commit();
          batch = db.batch();
          inBatch = 0;
        }
      }
      if (inBatch > 0) await batch.commit();
    }

    copied++;
    if (copied % 25 === 0) console.log(`  ... ${copied} docs copied`);
  }

  console.log(`\n[${oldName} -> ${newName}] copied=${copied} skipped=${skipped}`);
  return { copied, skipped };
}

async function deleteOld(name) {
  if (!APPLY || !DELETE_OLD) return;
  const db = getFirestore();
  const col = db.collection(name);
  const snap = await col.get();
  if (snap.size === 0) return;
  console.log(`Deleting ${snap.size} docs from ${name} ...`);
  let batch = db.batch();
  let count = 0;
  for (const doc of snap.docs) {
    batch.delete(doc.ref);
    count++;
    if (count === 400) {
      await batch.commit();
      batch = db.batch();
      count = 0;
    }
  }
  if (count > 0) await batch.commit();
  console.log(`Deleted old collection ${name}`);
}

async function main() {
  console.log(APPLY ? 'MODE: APPLY (writes data)' : 'MODE: DRY RUN (no writes)');
  console.log('Collections:');
  console.log(`  ${OLD.notes}  ->  ${NEW.notes}   (+ ${NEW.notes}/{id}/reviews)`);
  console.log(`  ${OLD.boughtNotes}  ->  ${NEW.boughtNotes}\n`);

  await copyCollection(OLD.notes, NEW.notes, { subcollections: ['reviews'] });
  await copyCollection(OLD.boughtNotes, NEW.boughtNotes);

  if (APPLY) {
    console.log('\nMigration written. Verify the new collections in the Console.');
    if (!DELETE_OLD) {
      console.log('Old collections NOT deleted. Re-run with --delete-old once verified.');
    }
  } else {
    console.log('\nDry run complete. Re-run with --apply to write the data.');
  }
}

main()
  .then(() => deleteApp())
  .catch((err) => {
    console.error('Migration failed:', err.message);
    process.exitCode = 1;
  });
