# Hajnal coding baseline import

Date: 2026-11-26. Requested by the user: copy exptv2 skills, agent instructions and Ponytail into Hajnal as coding principles.

## Pinned sources

- Repository: elizerpist/exptv2.
- Main: `fe10593ec833e41080186404c053e81e5889d623`; source AGENTS.md and 63 complete skill directories.
- Ponytail source: `fix/orb-v4-latency-lockscreen` at `4cbaf35cf6bcc28284e32bc5bf1badae4bec9850`; ponytail, ponytail-review and MIT license.
- Hajnal parent: `2ba70bc8e7a1ca0dac0d1abb7084b61520c309a4`, branch `feat/first-prototype-page`.
- All 155 skill/support/license files copied byte-for-byte, preserving source git file modes.
- Root AGENTS.md combines a Hajnal precedence/integration section, the complete source instructions, and the complete pre-existing Hajnal instructions.
- The old exptv2 SETUP-CHECKLIST.md describes mazeball setup; it is intentionally not copied as false Hajnal evidence.
- No app scaffold, dependencies, CI build jobs or prototype changes are introduced.

## Reference review and scope

The current Flutter specification and the existing Hajnal AGENTS.md govern this import. Earlier product specification and prototype acceptance checklist were reviewed during the preceding specification commit. No UI, geometry, navigation or visual design is changed here; PNG/rendering checks do not apply.

## Acceptance checklist

| ID | Requirement | Verification | Status |
| --- | --- | --- | --- |
| IMP-1 | Copy complete main skill collection | Source tree lists 63 SKILL.md manifests and all support files | DONE |
| IMP-2 | Include Ponytail and review | Two additional manifests plus ponytail-LICENSE | DONE |
| IMP-3 | Preserve source content and executable modes | Compare resulting git blob SHAs and modes against pinned source tree before branch update | Required publication gate |
| IMP-4 | Preserve Hajnal-specific rules and latest spec precedence | Root instructions include both source texts and explicit resolution | DONE |
| IMP-5 | Avoid foreign setup claims | No mazeball setup checklist imported | DONE |
| IMP-6 | Preserve application scope | Only agent instructions, inventory, provenance and skill files changed | Required publication gate |

Skill availability depends on the coding client's repository skill discovery. This import stores the complete repository-local collection; it does not claim an installed global plugin or tested runtime execution of every helper.
