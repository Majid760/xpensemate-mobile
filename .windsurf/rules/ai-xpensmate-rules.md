---
trigger: always_on
---

# WindSurf AI Rules — Flutter Clean-Architecture Project
# ------------------------------------------------------
# This file is read by Cascade before every generation / edit.
# Treat it as a living contract; update when conventions evolve.

## 0. Meta
- ALWAYS read this file before answering.
- ALWAYS read analysis_options.yaml and generate the code which comply 
  mentioned rules in file.
- NEVER violate a rule unless explicitly asked (and justify the exception).
- When uncertain, ask the user for clarification instead of guessing.

## 1. Language & Tooling
- Language: **Dart 3.5+**, null-safety ON.
- Framework: **Flutter stable (>= 3.32)**.
- State-management: **BLoC (Cubit)** exclusively.
- DI: **get_it** + **injectable**.
- Routing: **go_router**.
- Code-gen: **build_runner**, **freezed**, **json_serializable**.
- Testing: **flutter_test**, **bloc_test**, **mocktail**.

## 2. Project Structure (Clean Architecture)

lib/
├─ core/               # Cross-cutting concerns
│   ├─ error/
│   ├─ network/
│   ├─ theme/
│   └─ utils/
├─ features/
│   └─ <feature_name>/
│       ├─ data/
│       │   ├─ datasources/
│       │   ├─ models/
│       │   └─ repositories/
│       ├─ domain/
│       │   ├─ entities/
│       │   ├─ repositories/
│       │   └─ usecases/
│       └─ presentation/
│           ├─ cubit/
│           ├─ pages/
│           └─ widgets/
├─ l10n/
└─ main.dart

- **NEVER** mix layers (e.g., import `data/` inside `domain/`).
- **One feature per folder**; no “shared” mega-folders.
- Barrel files (`index.dart`) are forbidden; use explicit exports.

## 3. Naming & Style
- **lowerCamelCase** for variables, functions, methods.
- **UpperCamelCase** for classes, enums, typedefs, extensions.
- **SCREAMING_SNAKE_CASE** for constants.
- **lower_snake_case** for files and folders.
- Prefer **immutability**: `final` > `var`; collections via `const`.
- Lines ≤ 80 chars (except unavoidable strings).

## 4. State-Management Rules (Cubit)
- One **Cubit** per screen OR cohesive feature slice.
- Cubit state classes: **immutable**, `@freezed`.
- Emit only **new** state objects (`state.copyWith(...)`).
- **No logic in widgets**; extract to use-cases or cubits.
- Use `BlocListener` for side-effects, `BlocBuilder` for UI rebuilds.
- **No events generation use states e.g ( enum HomeStates { initial, loading, loaded, error })

## 5. SOLID & Clean
- **Single Responsibility** – one class per reason to change.
- **Open/Closed** – extend via abstract classes / DI, never modify core.
- **Liskov** – subtype must be substitutable; no runtime casts.
- **Interface Segregation** – small repository contracts (`IFooRepository`).
- **Dependency Inversion** – widgets & cubits depend on abstractions (`domain/`).
- **Comment Rule** - comment for configuration/setup files,use this pattern  
// ------------------------------------------------------------------
//  Auth & Global headers
// ------------------------------------------------------------------ 

## 6. Dependency Injection
- Register all objects via `@injectable` + `get_it`.
- Constructor injection for **testability**; no `GetIt.I<Foo>()` inside domain.
- Environment-aware modules (`@prod`, `@dev`, `@test`).

## 7. Error Handling
- Domain layer throws **custom failures** (subclass of `Failure`).
- Data layer maps exceptions → `Failure` in repositories.
- Presentation shows **user-friendly messages** via `BlocListener`.
- No `print()` or `catch (e) {}`; use `log()` or `talker`.

## 8. Testing
- **100 % unit-test coverage for use-cases & cubits**.
- Widget tests for pages with **golden-file comparison**.
- Mock via `mocktail`, **never** mock 3rd-party SDKs directly (wrap them).
- Test file mirrors source, named `<original>_test.dart`.

## 9. Null-Safety & Immutability
- **No `!` operator** unless proven safe (document with `// safety:` comment).
- Prefer **non-nullable** types; late-initialisation only with `late final`.
- Use **collection-if / collection-for**; avoid `.toList()!`.

## 10. Performance & UX
- `const` constructors everywhere possible.
- Avoid `BuildContext` across async gaps (`mounted` check).
- Use `ListView.builder` for >10 items.
- Images: precache, cacheWidth/cacheHeight, `gaplessPlayback`.

## 11. Lints & Formatting
- Enable **all** recommended lints (`analysis_options.yaml` below).  
  ```yaml
  include: package:flutter_lints/flutter.yaml
  linter:
    rules:
      - always_use_package_imports
      - avoid_dynamic_calls
      - prefer_single_quotes
      - require_trailing_commas

## 12. Security
- **Never commit secrets** (API keys, tokens, certs, keystore passwords).  
  Store them in:
  - `--dart-define` variables, or  
  - `.env` files listed in `.gitignore`, or  
  - platform-specific secret stores (Keychain / Keystore).  

- **Validate all untrusted JSON** via `checked_json`, `freezed`, or explicit `fromJson` factories.  
- **Mask sensitive data** in logs (tokens, emails, PII).  
- **Use HTTPS only**; reject self-signed certs in production.

## 13. Git Hygiene
- Commit messages must follow **Conventional Commits** (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`).  
  Example: `feat(auth): add biometric login use-case`.

- Each commit must compile and pass `flutter analyze` + unit tests.  
- Pull-request template checklist (auto-generated):
  - [ ] Tests added or updated
  - [ ] Golden screenshots updated (if UI change)
  - [ ] No analyzer / lint warnings
  - [ ] CHANGELOG entry added (if user-facing)

- Rebase feature branches onto `main`; no merge commits in PRs.  
- Force-push only on personal feature branches.


## 14. Documentation
- **Public APIs** (classes, top-level functions, repositories) require concise `/// dartdoc`.  
- **Complex algorithms** get inline `//` comments explaining **why**, not **what**.  
- README must include:
  - 1-line elevator pitch
  - Setup steps (Flutter version, `flutter pub get`, `build_runner` command)
  - Minimal `.env` template
  - Screenshot / GIF of main screen (kept up-to-date)

## 15. Re-use & DRY
- Before **adding any new widget or utility**, search `lib/` and confirm:
  - No existing widget covers the same use-case (even with minor param tweak).  
  - No existing use-case / repository / extension already solves the problem.  
  If a near-match exists, **refactor/generalise first**; duplication is forbidden.

## 16. Responsiveness & Device Support
- **Every screen and custom widget** must render correctly on:
  - Phones (small ≤ 360 dp, large ≤ 600 dp)
  - 7" & 10" tablets
  - iPad split-view (Slide-Over & 50/50)
  - Foldables (portrait & landscape)

- Use:
  - `LayoutBuilder` / `MediaQuery` for breakpoints
  - `FittedBox`, `Expanded`, `Flexible` for text & icons
  - `ResponsiveRowColumn` from `flutter_layout_grid` when needed
  - Vector SVGs or 2×/3× PNGs; no hard-coded pixel sizes

- Run `flutter test integration_test/responsive_test.dart` on CI.


## 17. Accessibility & UX Polish
- All tappable targets ≥ 48 × 48 dp.  
- Provide semantic labels (`Semantics`, `tooltip`) for every icon-only button.  
- Color contrast ratio ≥ 4.5 : 1 (WCAG AA).  
- Support **dark & light mode** without extra effort (use `Theme.of(context)`).  
- Respect system text-scale (no `textScaleFactor` clamping).

## 18. Performance Budget
- First build of any screen < 16 ms on a mid-tier Android device (profile mode).  
- Images: always specify `cacheWidth`/`cacheHeight` for thumbnails.  
- Debounce search fields (≥ 300 ms).  
- Use `ListView.builder` or `SliverList` for >10 items.  
- No `setState` outside tests; prefer `BlocBuilder` or `BlocSelector`.


## 19. Error & Crash Handling
- Top-level zones catch & report to Crashlytics / Sentry.  
- Show **localised**, user-friendly error messages; never raw stack traces.  
- In dev mode, display a red **dev-only banner** on error states for visibility

## 20. Final Checklist (run mentally before every generation)

[ ] Re-use existing code?  
[ ] Responsive on all devices?  
[ ] Null-safe & lint-clean?  
[ ] Tests cover new branch?  
[ ] Docs updated (README / dartdoc / CHANGELOG)?  
[ ] Secrets not leaked?