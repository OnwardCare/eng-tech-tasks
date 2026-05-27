<!-- LEDGER_DESIGN.md -->
# Ledger Design: Append-Only Transaction History

## Why an Append-Only Ledger

Rather than storing `balance` as a mutable column, this platform should use an append-only `trader_transactions` table. Reasons:

- **Auditability** — every credit and debit is a permanent record; you can look up what a trader's balance was at any point in time
- **Concurrency** — inserting a row is atomic; the previous `balance +=` pattern was a race condition under concurrent requests
- **Immutability** — state is never overwritten, making it possible to replay history and correct bugs after the fact

---

## Exercise

Refactor the platform to use an append-only ledger and implement the new balance endpoint.

### 0. Assume the application has data in traders already, so we need to backfill the new table.
- Assume 50M records

### 1. Migrate the schema

- Remove the `balance` column from `traders`
- Create a `trader_transactions` table with a `decimal` `amount` column and a foreign key to `traders`

### 2. Update the application

- Update the `Trader` model so that `balance` is derived from `trader_transactions`
- Update the existing endpoints so they continue to work correctly with the new schema

### 3. `GET /trading/traders/balance?email={email}`

New endpoint. Returns the current balance for a trader identified by email.

- **200** — trader found; returns `{ "balance": <decimal> }`
- **404** — no trader exists with the given email
