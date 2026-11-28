# ADR 003: Quarantine bad rows instead of deleting them or letting them through

## Status
Accepted

## Context
Dbt tests and Pandera checks detect bad data, but detection alone leaves bad rows in the marts. Silent deletion would hide the problem.

## Decision
- Staging checks flag duplicate order IDs, orphan customers, invalid statuses, delivery before purchase, review scores outside 1-5, and negative payments.
- Failing rows go to quarantine tables with the failed check and a timestamp.
- Only clean rows (stg_*_valid models) feed the marts.
- A warning-level dbt test reports quarantine counts on every run.
- Tested by injecting known bad records into a copy of the database.

## Consequences
- The marts stay clean, and the problems stay visible and countable.
- Quarantined rows still need a human or a source fix.
- Orders that fail their own checks are dropped from the marts entirely, while bad reviews or payments only lose that value.
