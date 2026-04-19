# Project Guidelines and Context for AI Agents (Antigravity & Gemini CLI)

## Important Directives
This file (`gemini.md`) provides mandatory instructions and architectural rules for any AI agent modifying, analyzing, or interacting with the code in this repository (Pizzathon). The directives in this file MUST be **strictly followed**.

---

## 1. Architecture: Clean Architecture
This project meticulously follows **Clean Architecture** principles. You must respect layer boundaries and component separation at all times.

### Core Rules
1. **Dependency Rule (Direction):** Inner layers (e.g., `Domain`) MUST NEVER depend on outer layers (e.g., `Data`, `UI`). Dependencies ALWAYS point inwards: `UI` -> `Domain` <- `Data`.
   - **Prohibited:** Importing code from `lib/ui/` or `lib/data/` inside `lib/domain/`.
   - **Prohibited:** Importing pure UI libraries (like Flutter Material) into `domain` or `data` unless there is a strong, cross-cutting architectural justification.
   
2. **Intra-Layer Independence (Component Isolation):** A component or feature within a specific layer MUST NOT depend directly on another component in its same layer.
   - *UI Example:* The `admin` page (`lib/ui/pages/admin`) cannot import anything from the `home` page (`lib/ui/pages/home`). If they share logic or interfaces, it must be abstracted to `lib/ui/widgets/` or `lib/ui/blocs/`.
   - *Data Example:* `auth_service.dart` will not directly instantiate or depend on `firestore_service.dart`. Communication or joint usage must be orchestrated through repositories, use cases, or state managers (Bloc/Cubit).

3. **Total Decoupling:** Infrastructure details (Firebase Auth, Firestore, external APIs, SharedPreferences) must be kept isolated within the `Data` layer. 
   - The `UI` layer should never directly import a Firebase package (e.g., `import 'package:cloud_firestore/cloud_firestore.dart'`).
   - Data fetching or destructive actions must always be dispatched through the corresponding methods in `lib/ui/blocs/`.

---

## 2. Repository Map and Context
Below is a detail of the main structure (`lib/`) of Pizzathon to understand where each piece of new code belongs:

### `lib/domain/` (The Core)
Contains purely business logic, entities, and interfaces that know nothing about infrastructure or the UI.
- **`/models/`**: Contains Models, DTOs, and pure extensions. *Ex: `user_model.dart`, `compression_settings.dart`, `user_extension.dart`.*

### `lib/data/` (The Infrastructure)
Contains technical implementations communicating with the outside world (Databases, network, APIs, device services).
- **`/services/`**: Concrete implementations. All code coupled to databases or external services resides here. *Ex: `auth_service.dart`, `firestore_service.dart`, `image_processing_service.dart`, `local_storage_service.dart`, `remote_config_service.dart`.*

### `lib/ui/` (The Presentation)
Contains everything related to user visualization and interactions in Flutter.
- **`/blocs/`**: The application's state. These connect the UI to the services/use cases. *Ex: `auth_cubit.dart`.*
- **`/pages/`**: Primary user screens, heavily segregated by feature. *Ex: `/admin`, `/home`, `/landing_page`, `/poc_images`, `profile_page.dart`.* Pages are NEVER imported between each other; navigation is orchestrated in **`app_router.dart`** using `GoRouter`.
- **`/widgets/`**: Generic, reusable visual components across the system. If a piece of UI can be used by both `home` and `admin`, it belongs here. *Ex: `app_shell.dart`, `user_list_item_widget.dart`.*
- **`/theme/`**: Stylistic definitions and constants ensuring cohesive design. *Ex: `theme.dart`.*

---

## 3. Code Style and Formatting
- **Line Length limit:** The absolute maximum line length allowed in Dart code and configurations is **100 characters** per line. (This is strictly enforced in `.vscode/settings.json` via `"dart.lineLength": 100`). When coding for this project, your lines must not exceed this limit.
