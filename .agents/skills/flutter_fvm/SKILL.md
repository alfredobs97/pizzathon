---
name: flutter_fvm
description: "Rules for Flutter execution. Use this whenever running flutter run, build, test, or pub commands."
---
## PRIME DIRECTIVE

> **CRITICAL:** This project uses FVM for version control.
> **YOU MUST USE `fvm` PREFIX FOR ALL FLUTTER AND DART COMMANDS.**
> **NEVER use global `flutter` or `dart` commands directly.**

## 1. Mandatory Command Syntax
Every single interaction with the Flutter or Dart SDK **MUST** be prefixed with `fvm`.

- **WRONG (Forbidden):** `flutter run`
- **WRONG (Forbidden):** `dart format .`
- **CORRECT (Mandatory):** `fvm flutter run`
- **CORRECT (Mandatory):** `fvm dart format .`

## 2. Execution Protocol for Agents
When you need to execute a task, follow this decision tree:

1.  **Check Tooling:** Do NOT use abstract tools like `run_flutter_tests` or `build_app` unless you can explicitly configure them to use the `fvm` binary.
2.  **Preferred Method:** Use the `bash`, `shell`, or `terminal` tool to execute the raw command string.
3.  **Verify String:** Before hitting "enter", verify the command string starts with `fvm`.

### Command Mapping Table
| Intent | FORBIDDEN Command | REQUIRED Command |
|--------|-------------------|------------------|
| Run App | `flutter run` | `fvm flutter run` |
| Install Deps | `flutter pub get` | `fvm flutter pub get` |
| Add Package | `flutter pub add` | `fvm flutter pub add` |
| Run Tests | `flutter test` | `fvm flutter test` |
| Analyze Code | `flutter analyze` | `fvm flutter analyze` |
| Format Code | `dart format` | `fvm dart format` |
| Fix Issues | `dart fix` | `fvm dart fix` |

## 3. Initialization & Setup (First Steps)
If you are starting a task or switching branches, you must ensure the specific Flutter version is installed locally.

1.  **Check Status:** Run `fvm flutter --version`
2.  **If "Command not found" or Version Error:**
    - DO NOT fall back to global flutter.
    - EXECUTE: `fvm install`
    - Wait for installation, then proceed.

## 4. Context Awareness
- **Monorepos/Subdirectories:** If working inside `widgetbook/` or other sub-packages, check for a local `.fvmrc` or config.
- **Root Config:** The truth source is `.fvm/fvm_config.json`.

## 5. Troubleshooting (Self-Correction)
If a command fails with "command not found" or SDK errors:
1.  **STOP.** Do not try without `fvm`.
2.  Check if `fvm` is installed in the environment (`which fvm`).
3.  Run `fvm install` to ensure the SDK is cached.
4.  Retry the command with the `fvm` prefix.