# Text-to-SQL on Synthetic Patient Data: v1 Spec

## User
Clinicians and analysts who need answers from patient data but do not write SQL.
v1 runs on the Synthea 1K synthetic dataset (no real patient data).

## Goals
- Answer English questions about the dataset by generating and running SQL
- Show, for every answer: the SQL, the assumptions made, the result table, a one-line explanation
- Provide an eval script that scores the system against the eval set with one command
- Rebuild the clean database from the raw CSVs with one command

## Non-goals (v1)
- No clinical advice, diagnosis or treatment suggestions
- No real patient data
- No write operations of any kind
- No multi-turn conversation (each question is independent)
- No charts, no authentication, no multi-user support
- English only, SQLite only
- No FHIR ingestion (planned as project 1b)

## Flow
1. User types a question in the web page
2. System builds the prompt: data dictionary + data conventions + rules
3. Claude returns SQL plus the assumptions it made
4. Safety check validates the SQL (see Safety)
5. Query runs on the clean database, read-only, with timeout and row limit
6. Page shows assumptions, SQL, results and explanation
7. On SQL error: one retry, sending the error back to Claude; then show the error

## How the four core problems are handled

**Ambiguity.** The model never silently picks an interpretation: it must state its
assumptions, shown to the user. Default conventions are documented and given to
the model: "patients" = distinct patients; "latest" = most recent per patient;
"currently" = living patients only; clinical thresholds per ESC 2024 unless stated.

**Schema knowledge.** A data dictionary (tables, columns, types, meaning) plus the
exact names of common lab tests and conditions, included in every prompt.
Exact-match on names (=) is preferred over LIKE.

**Plausible-but-wrong queries.** Fixed at the source, not in the prompt: a load
script builds a clean database (numeric values as REAL, empty strings as NULL,
consistent dates). Known traps are documented (e.g. LIKE '%diabetes%' matches
Prediabetes). The eval set catches regressions. Showing SQL and assumptions lets
the user verify.

**Safety.** Read-only database connection. Only a single SELECT or WITH statement
is accepted; anything else is rejected before execution. Row limit and timeout on
every query. API key in .env, never committed.

## Acceptance criteria (v1 is done when)
- Clean database rebuilds from raw CSVs with one command
- Eval script runs with one command and reports a score
- Score >= 8/10 on the eval set, with all easy questions correct
- 0 of 5 malicious prompts (e.g. "delete all patients") result in a write
- README explains what the project does and how to run it

## Interface
Web page built with Streamlit: Python only, no frontend code to learn, and easy to
demo for a portfolio. Eval and load scripts run from the command line.

## Open questions
- Eval set SQL must be updated to the clean schema (e.g. Q7 uses DEATHDATE = '')
- Should the system ask a clarifying question instead of assuming? (v2 candidate)