# Onboarding architecture card

## Scope and sources
- User's complete onboarding request, overriding the native-picker requirement.
- Visual references: `docs/references/source-of-truth/boarding1.png`, `boarding2.png`, `onboarding.png`, `designnkovetelmenyek.png`; original `welcome_svg.svg`, `assets/brand/logo.svg`.
- Existing: `lib/features/onboarding`, `lib/features/recovery`, `lib/app`, `lib/core/database`, `lib/core/theme/hajnal_tokens.dart`; `html-prototypes/app-shell/index.html` initialization flow. Flutter spec §§2–3, 8, 11–14, 19.
- Both supplied images show pale pink background, off-white rounded cards, dark blue text, purple actions and a clear heading hierarchy. The date page embeds a calendar; sponsor fields expand inline. User text supersedes illustration, page order, disclaimer and example selections.

## Single source and write path
- SQLite owns committed recovery period, personal motivation, optional modules, sponsor contact and completion. The durable draft is a separate row and never becomes active until finalization.
- The onboarding controller owns the in-memory editing session and serializes draft writes. An application use case invokes one repository transaction, using the existing recovery repository for period operations; each persisted field is updated only when edited. A stale or closed period fails safely. Failed writes retain the draft and leave committed data unchanged.
- Date validation/counting uses `recovery/domain/calendar.dart`; the existing `DayTracker.calendarDay` publishes midnight/clock changes even before a period exists, without a second timer; artwork and brand use existing assets and theme tokens. Existing lifecycle and lock gate remain sole owners of locking and background state.

## State and boundaries
| State | Owner | Lifetime |
| --- | --- | --- |
| navigation and draft edits | onboarding controller | flow; persisted draft survives restart |
| committed date | RecoveryRepository | active period |
| motivation, modules, contact | corresponding persistent records | across periods and app restarts |
| derived day count | existing calendar domain | computed |
| lock/lifecycle | LockController and HajnalApp | application session |

UI → controller → finalization use case → repository transaction → Drift/SQLite. UI handles rendering, focus and intents only. Existing lock wraps the entire navigator. Common onboarding shell owns page geometry; no new parallel theme, date engine, lifecycle observer or authentication.

## Verification
- Transaction rollback, concurrent/double completion, ordered draft writes, stale period and changed-only updates; migration from v2 and persistence after reopen.
- Widget flow order, branching, back/close, initial and edit states, accessibility and small screens; existing date and lock regressions.
- Boundary dependency graph and writer-owner contracts; full local analysis/tests.
- All pages captured together on emulator and reviewed against both source screenshots, including expanded sponsor, small viewport and keyboard. Existing CI builds and release review, same signing and upgrade tests.

A `presentation/onboarding.dart` 500 sor feletti: a jelenlegi review szerint egyetlen felelőssége a flow képernyőinek renderelése és intentjeinek továbbítása; tárolást, dátumszámítást és életciklust nem tartalmaz. További oldalak vagy eltérő megjelenítők esetén az oldalankénti renderereket külön fájlokba kell emelni, a közös controller és keret megtartásával.

## Ponytail és boundary önellenőrzés

A szerkesztési állapot és a rendezett piszkozatírás tulajdonosa az `OnboardingController`; a záró műveletet a `FinishOnboarding` validálja. Az `OnboardingRepository` egy Drift-tranzakcióban alkalmazza a profil és piszkozat állapotát, az aktív időszakot kizárólag a `RecoveryRepository`, a kapcsolatot kizárólag a `SponsorRepository` írja. Az import- és AST-alapú boundary suite ellenőrzi a rétegirányt, a konkrét táblák íróit és a tiltott függőségeket. Az emlékeztető és modulválasztások az egyetlen profilrekordban, a szponzoradat külön egyetlen kapcsolatrekordban élnek; nincs időszakmásolatuk. A még el nem készült pánik- és szponzorképernyő nem kapott látszatimplementációt.

A review során a zárás és függő automentés közti lehetséges adatvesztést `flushDraft` rendezi: hibánál a felület nyitva marad, és az írás újrapróbálható. Az éjféli előnézet a `DayTracker.calendarDay` read-only jelzését használja; nem jött létre új időzítő. A végleges vizuális és CI-bizonyítékok állapotát az elfogadási lista jelzi.
