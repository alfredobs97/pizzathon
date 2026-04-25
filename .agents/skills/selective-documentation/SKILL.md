---
name: selective-documentation
description: Guidelines for high-impact, selective English code documentation.
risk: low
source: user
date_added: '2026-04-20'
---

## Use this skill when
- Modifying or creating source code.
- Defining APIs, interfaces, or complex business logic.
- Making significant architectural or design decisions that require explanation.

## Do not use this skill when
- Writing trivial or self-explanatory code (e.g., standard getters, simple UI layouts, boilerplate).
- The code's purpose and flow are immediately obvious from the naming and structure.

## Instructions
- **Language**: All documentation, comments, and docstrings MUST be in English.
- **Selectivity**: Do not document everything. Only add comments when they provide value that the code itself does not express.
- **What to document**:
    - **Interfaces & Public APIs**: Explain the *purpose* and *usage* of public methods and classes.
    - **Complex Logic**: Describe *why* a particular algorithm or complex logic block is implemented that way.
    - **Design Decisions**: Document the rationale behind non-obvious architectural choices.
    - **Constraints & Edge Cases**: Highlight assumptions or specific conditions that the code handles (or ignores).
- **Format**:
    - Use `///` (triple-slash) for documentation comments (DartDoc) on classes, members, and methods.
    - Use `//` for internal implementation notes.
- **Conciseness**: Keep documentation brief and to the point. Focus on "Why" more than "What" (the code already shows "What").

## Example
### Good (Meaningful Documentation)
```dart
/// Manages the paginated fetching of pizza records from Firestore.
/// 
/// We use a custom Cubit instead of a simple Stream to allow for 
/// explicit manual triggers and easier error handling in the UI.
class PizzaListCubit extends Cubit<PizzaListState> { ... }
```

### Avoid (Redundant Documentation)
```dart
// Sets the pizza name
void setPizzaName(String name) { ... }
```
