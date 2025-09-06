# Event Payment Update API Request Format

This document describes the exact JSON structure and field expectations for updating payment status of participants in an event (solo or team) using `EventApi.updatePaymentStatus`.

---
## Endpoint
```
POST /api/v1/event/update_payment/:eventId
```
`eventId` is the MongoDB/DB identifier of the event whose participant payment status you want to update.

### Final URL Example
```
http://<SITE_LINK>/api/v1/event/update_payment/6840df1e12ab901234567890
```
Where `<SITE_LINK>` is `Secret.siteLink` (production or development host value).

---
## Headers
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```
`<JWT_TOKEN>` is obtained during authentication and stored via `Tokenprocess.readToken()`.

---
## Base Body Structure
```json
{
  "slug": "21063",
  "members": [ /* Array<PaymentMember> */ ],
  "paymentStatus": true /* OPTIONAL */
}
```
### Required Fields:
- `slug` (string): Numeric slug identifying the acting admin / club instance. Always included.
- `members` (array): List describing each participant whose payment status is being set.

### Optional Field:
- `paymentStatus` (boolean): Global override to apply the same status to every member in `members`. (Your current Flutter client code does NOT set this unless you explicitly supply it.) If omitted, each member object must carry its own `status` field.

---
## PaymentMember Object Forms
Each element in `members` must be one of the following shapes (only one identification method per object):

1. By userId:
```json
{ "userId": "6840df1e12ab901234567000", "status": true }
```
2. By classroll (numeric):
```json
{ "classroll": 21063, "status": false }
```

### Field Rules
- `userId` (string) OR `classroll` (number) must be present. Never both.
- `status` (boolean) required unless the top-level `paymentStatus` field is provided.
- No extra properties should be sent (avoid bloating the payload).

---
## Solo Event Update Example
Toggle mixed participants (some by userId, some by classroll):
```json
{
  "slug": "21063",
  "members": [
    { "userId": "6840df1e12ab901234567111", "status": true },
    { "classroll": 21045, "status": false },
    { "userId": "6840df1e12ab901234567222", "status": true }
  ]
}
```

## Team Event Batched Per Team (Current Client Logic)
Your client sends one request PER TEAM. Each request includes all members of that team with a unified status (derived from the team toggle):
```json
{
  "slug": "21063",
  "members": [
    { "userId": "6840df1e12ab901234567333", "status": true },
    { "classroll": 21077, "status": true },
    { "userId": "6840df1e12ab901234567444", "status": true }
  ]
}
```
If another team is set to unpaid, a second request is sent:
```json
{
  "slug": "21063",
  "members": [
    { "userId": "6840df1e12ab901234567555", "status": false },
    { "userId": "6840df1e12ab901234567666", "status": false }
  ]
}
```

---
## Optional Global Toggle Pattern (Not Currently Used)
If the backend supports applying the same status to all, you could send:
```json
{
  "slug": "21063",
  "paymentStatus": true,
  "members": [
    { "userId": "6840df1e12ab901234567111" },
    { "classroll": 21045 },
    { "userId": "6840df1e12ab901234567222" }
  ]
}
```
Backend would apply `paymentStatus: true` to all entries. (Only implement if confirmed by backend docs.)

---
## Error Prevention Checklist
- Ensure `eventId` path param is not empty.
- Ensure `members` is a non-empty array when making a request.
- Do not include UI-only fields (names, teamName, etc.).
- Do not send both `userId` and `classroll` in the same object.
- Keep numbers numeric (no quotes around classroll).
- Refresh events after success to sync local state.

---
## Flutter Client Snippet (Solo Example)
```dart
final membersPayload = selection.entries.map((e) {
  final key = e.key; // formats: id:<mongoId> or cr:<roll>
  final status = e.value; // bool
  if (key.startsWith('id:')) {
    return {'userId': key.substring(3), 'status': status};
  }
  return {
    'classroll': int.tryParse(key.substring(3)) ?? 0,
    'status': status,
  };
}).toList();

await EventApi.updatePaymentStatus(
  eventId: event.id!,
  members: membersPayload,
);
```

---
## Full cURL Example
```bash
curl -X POST \
  "http://<SITE_LINK>/api/v1/event/update_payment/6840df1e12ab901234567890" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "slug": "21063",
    "members": [
      { "userId": "6840df1e12ab901234567111", "status": true },
      { "classroll": 21045, "status": false }
    ]
  }'
```

---
## Response (Typical Success Skeleton)
```json
{
  "success": true,
  "message": "Payment status updated",
  "updatedCount": 3
}
```
(Exact fields depend on backend.)

---
## Summary
Minimal, lean payload = slug + members[] (+ optional paymentStatus). Each member: one identifier + optional status. Team mode loops per team in current implementation.

Update this doc if backend changes contract (e.g., adds partial failure reporting, per-member errors, etc.).
