# VillaBooks Agent Instructions

VillaBooks is a Flutter property management app.

Architecture:
- Flutter mobile app
- Firebase Auth
- Cloud Firestore
- Firebase Storage for room media
- Drift/SQLite local database
- Riverpod state management
- Offline-first sync
- Admin, Contributor, Reader roles

Important rules:
- Do not change Firestore schema unless issue clearly asks.
- Do not add extra Firestore fields just to solve UI problems.
- Do not modify unrelated modules.
- Do not break Firebase sync.
- Do not break rent calculations.
- Do not modify income/expense flow unless issue is about income/expense.
- Store media files in Firebase Storage, not Firestore.
- Firestore stores only media metadata.
- Use soft delete with isDeleted.
- Dashboard must ignore deleted records.
- Keep existing UI direction unless issue asks for UI change.

Workflow:
- Read GitHub issue title and body.
- Implement only the requested change.
- Run build_runner if generated files are affected.
- Create a PR for human review.