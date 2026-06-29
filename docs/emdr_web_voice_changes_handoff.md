# EMDR Web Voice Changes — App Implementation Handoff

Last reviewed: 29 June 2026  
Primary scope: `emdr-web` EMDR Companion summary and Bilateral Simulation (`EMDR Processing`)  
Reference route: `/dashboard/resources/bilateral/session?environment=plain-background&icon=plain-ball&sound=6a33c1f4a22d4d3e1c50199e&speed=faster&direction=horizontal`

## 1. What changed

The recent voice work is mainly in two commits:

- `c572ae3` (27 June 2026): added and wired recorded client voice prompts, added the audio audit, and extended the body-scan voice flow.
- `14ed43e` (29 June 2026): removed browser `speechSynthesis` from the Bilateral Session, moved dynamic narration to authenticated ElevenLabs TTS, added caching/deduplication/cancellation, changed the summary wording, and made most state transitions wait for successful voice completion.

The main code locations are:

- `emdr-web/src/app/dashboard/EMDRCompanion/page.jsx`
  - Builds the roadmap summary text.
  - Completes the EMDR session through the backend.
  - Stores the backend-generated summary audio URL, text, and provider in `localStorage`.
- `emdr-web/src/app/dashboard/resources/bilateral/session/page.jsx`
  - Reads the saved roadmap/summary.
  - Plays intro, summary, recorded prompts, dynamic TTS prompts, Calm Place prompts, and closure prompts.
  - Owns the processing voice/state-machine synchronization.
- `emdr-web/public/voice/`
  - Runtime paths currently used by the hard-coded client prompt map.
- `emdr-web/public/client-voice-prompts/`
  - Audited copies of the same six recorded prompts. These are not the paths referenced by the current session page.
- `emdr-web/AUDIO_AUDIT_REPORT.md`
  - Sample-level audit for the six recorded WAV prompts.

`src/services/voice/voiceRegistry.js` and `voicePlayback.js` currently contain only `// Last implementation undone.` and are not part of the active implementation.

## 2. End-to-end data flow

### A. EMDR Companion creates the summary

At Companion completion, `createSummaryMarkup()` builds `roadmapSummaryText` from the user's target, emotions, body location, and negative/positive beliefs. The browser immediately stores this in:

```text
localStorage["lastEMDRSession"].summary.roadmapSummaryText
```

The frontend then calls:

```http
PATCH {BASE_URL}/api/emdr-session/{sessionId}/complete
Authorization: Bearer {token}
```

The app expects `result.data` to contain these backend-generated fields:

```json
{
  "roadmapSummaryAudioUrl": "https://...",
  "roadmapSummaryText": "...",
  "roadmapSummaryAudioProvider": "elevenlabs"
}
```

Those three fields are persisted at both the session root and inside `summary` in `lastEMDRSession`. The matching item in `emdrSessions` is also updated when a matching `sessionId` exists.

### B. EMDR Processing resolves the summary

On simulation load, `getStoredRoadmapAudioContext()` reads `lastEMDRSession` and resolves:

- intro audio URL;
- roadmap summary audio URL;
- roadmap summary text;
- roadmap audio provider.

A stored summary audio URL is trusted only when:

```text
roadmapSummaryAudioProvider == "elevenlabs"
AND the stored summary text is not recognised as an old-format summary
```

Old text is detected if it equals/contains any of:

- `Your roadmap summary is ready.`
- `The original memory or image you are working with is:`
- `The freeze frame is:`
- `The negative belief is:`

If the provider is missing/not `elevenlabs`, or the text is old, the web app ignores the stored audio and rebuilds the new summary text locally from saved session answers. This prevents an old voice recording from reading outdated copy.

### C. The `EMDR Processing` intro is gated by audio completion

The initial screen has `Play Summary / Pause Summary / Resume Summary`. The processing Start button remains disabled until the intro/summary sequence finishes.

Playback order:

1. Intro:
   - saved `introAudioUrl`, else
   - backend `/api/bilateral/config` → `instructionAudio.intro`, else
   - ElevenLabs TTS of the intro fallback text.
2. Roadmap summary:
   - trusted stored ElevenLabs `roadmapSummaryAudioUrl`, else
   - ElevenLabs TTS generated from `roadmapSummaryText`.
3. Ready prompt:
   - skipped if summary text already contains `when you are ready`;
   - otherwise recorded `/voice/when you are ready.wav`;
   - ElevenLabs fallback if the recorded file fails.
4. `hasRoadmapAudioCompleted = true`; only then can BLS start.

Intro fallback script:

> The bilateral stimulation will start now. Your roadmap is ready. When you start, let your mind wander. Your thoughts may go forward or backwards in time.

## 3. Summary copy changes

### Standard EMDR flow

Old structure:

```text
{target sentence}
The thoughts are {negative beliefs}.
You are feeling {emotions}.
It sits in {body location}.
The positive belief is/positive beliefs are {positive beliefs}.
Now, when you are ready and have this in mind, press start.
```

New structure:

```text
{target sentence}
You described feeling {emotions}, and it makes sense that this experience still feels important.
You notice some of this in {body location}.
The difficult thought(s) you noticed was/were: {negative beliefs}.
You are moving towards the belief(s): {positive beliefs}.
You do not need to force anything. When you feel ready, press start and gently notice what comes.
```

Target prefix remains dependent on session type:

- future → `You are imagining ...`
- words → `You are bringing to mind ...`
- difficult emotions → `You are focusing on ...`
- default → `You are remembering ...`

### Addiction flow

Changed wording:

- `You are focusing on ...` → `You are gently focusing on ...`
- `The positive feeling is ...` → `You have described the feeling as ...`
- `The image or shape that comes to mind is ...` → `Hold the image of ... lightly in mind.`
- final instruction → `There is no need to force anything. When you feel ready, press start and simply notice what comes.`

The app must use the same templates as the Companion. Otherwise the on-screen summary, backend-generated audio, and simulation fallback TTS can say different things.

## 4. Voice source priority

| Voice type | First choice | Second choice | Final fallback |
|---|---|---|---|
| Intro | saved intro audio | `/api/bilateral/config` intro | ElevenLabs `/api/voice/tts` |
| Roadmap summary | stored URL only when provider is `elevenlabs` and copy is current | — | ElevenLabs from rebuilt/current text |
| Six client prompts | hard-coded `/voice/*.wav` | config audio for keys not hard-coded | ElevenLabs from fallback script |
| Dynamic processing guidance | ElevenLabs | — | no audible voice; function returns `false` |
| Personalised Calm Place | ElevenLabs with pincode/word | — | no audible voice |
| Non-personalised Calm Place | config `calmPlace` audio | ElevenLabs | no audible voice |
| Timer/end-session prompts | config `endSession` audio | ElevenLabs | no audible voice |

Important: there is no browser/device TTS fallback anymore. Dynamic voice needs the authenticated API.

## 5. TTS API contract

Request:

```http
POST {BASE_URL}/api/voice/tts
Authorization: Bearer {token}
Content-Type: application/json

{
  "text": "Prompt text",
  "cacheNamespace": "phase1-complete"
}
```

Expected successful response:

```json
{
  "success": true,
  "data": {
    "audioUrl": "https://..."
  }
}
```

The web implementation caches the returned URL in memory by:

```text
{cacheNamespace}:{exact text}
```

It also deduplicates both in-flight TTS requests and in-flight playback requests. Only one session instruction audio is active at a time. Starting another prompt cancels the current one.

## 6. Recorded client prompts

The active hard-coded map is:

| Key | Trigger | Runtime file(s) | Audited duration |
|---|---|---|---:|
| `changingConnected` | normal BLS round completes | `/voice/is it still changing and connected.wav` | 6.255s |
| `changing` | user selects changing | `/voice/okgood go with that.wav`, then `/voice/go with where you left off.wav` | 3.309s + 2.554s |
| `stuck` | user selects stuck | `/voice/go with where you left off.wav` | 2.554s |
| `notChanging` | user selects not changing | `/voice/lets go back to the original image.wav` | 23s |
| `okContinue` | SUDS is greater than 1 | `/voice/ok lets continue.wav` | 12.96s |
| `ready` | intro/summary ends and summary did not already say it | `/voice/when you are ready.wav` | 5.341s |

All audited versions are 44.1 kHz, stereo, 16-bit PCM WAV, with 50 ms fade-in/fade-out and no detected clipping. For the app, use a single canonical copy of each file; the web repository currently contains duplicates in `public/voice`, `public/client-voice-prompts`, and `public/audio-original-backup`.

## 7. Dynamic voice inventory and state transitions

| State/event | Cache namespace | Spoken content / behavior | Next action |
|---|---|---|---|
| Saved session restored | `session-restored` | `Your saved session has been restored.` | Resume saved state after audio |
| User opens direction change | `direction-change` | Explains Horizontal, Vertical, Diagonal Up, Diagonal Down | Continue enabled after audio and a different direction are selected |
| SUDS ≤ 1 | `phase1-complete` | `Great job. This part is complete. Let's strengthen the positive belief.` | `PHASE2_VOC` |
| Enter VOC rating | `voc-rating` | Original image + active positive belief; rate 1–7 | Await rating |
| VOC < 6 | `voc-installation` | `Lovely! Keep going.` + personalised positive-belief installation instruction | Start `PHASE2_BLS` |
| VOC ≥ 6 and more beliefs exist | `voc-next-belief` | `Good. Let's check in with the next positive belief.` | Rate next belief |
| VOC ≥ 6 and last belief | `voc-complete` | `Good. Let that settle for a moment.` | `PHASE2_COMPLETE` |
| Phase 2 BLS round completes | `phase2-notice` | `What do you notice now?` | `PHASE2_NOTICE` |
| Phase 2 negative response | `instruction-negativeBranch` | `OK good, keep going.` | Resume BLS |
| Enter body scan | `body-scan-intro` | Scan from head downward and report sensations | Await clear/unsure/sensation |
| Body scan clear | `body-scan-clear` | `Good. Your body scan is clear. This part is complete.` | `PHASE3_COMPLETE` |
| Body scan unsure | `body-scan-unsure` | Pause and notice body, then another short BLS round | `PHASE3_BLS` |
| Sensation present | `body-scan-sensation` | Look closely at sensation; focus and press Start | `PHASE3_SENSATION` |
| Sensation details submitted | `body-sensation-process` | Process sensation and do not let mind wander | `PHASE3_BLS` |
| Sensation BLS completes | `body-sensation-feel-now` | `How does that sensation feel now?` | Await text response |
| Feeling submitted | `body-sensation-left` | `Is there anything left in that sensation?` | yes/no choice |
| Sensation remains | `body-sensation-additional-round` | Focus on sensation and do not let mind wander | Another `PHASE3_BLS`, maximum 4 extra cycles |

Other voice cases:

- Personalised Calm Place: `Please bring up your pincode, {word}, and spend a minute finding that nice feeling in the body.` Namespace: `calm-place-personalised`.
- Non-personalised Calm Place: same text without `{word}`; config key `calmPlace`, then ElevenLabs namespace `instruction-calmPlace`.
- Five-minute closure: config key `endSession`, fallback asks the user to return to the original image and save the current emotion rating before Calm Place.
- Timer expiry: config key `endSession`, fallback says the session is ending and returns to Calm Place.
- Manual safe end: config key `endSession`, fallback asks the user to return to the room and use Calm Place if needed.

## 8. Playback/state rules the app must preserve

1. Keep one narration player separate from the bilateral left/right sound player.
2. Starting a new narration must cancel the currently active narration and resolve its pending operation as cancelled.
3. Do not start/resume BLS until the required instruction audio has ended successfully.
4. Do not allow Start until the intro and summary sequence is marked complete.
5. Pause/resume controls apply to the summary narration player.
6. Prefetch intro and summary TTS after authentication and summary context load.
7. Deduplicate TTS generation and playback using `namespace + exact text`.
8. Persist enough state to restore the active phase, summary context, SUDS/VOC values, body-scan draft, body-sensation cycle count, timer, and selected direction.
9. On dispose/navigation, stop narration, BLS audio, timers, and pending playback callbacks.
10. Keep recorded instruction audio and bilateral stimulation sound on separate channels so a prompt cannot be mistaken for an endpoint hit.

## 9. Recommended Flutter implementation split

Avoid porting the entire React page into one Dart widget. Use these responsibilities:

```text
VoiceApiClient
  POST /api/voice/tts

SessionNarrationController
  single active narration
  play asset / URL
  pause / resume / cancel
  URL + in-flight request cache
  playback deduplication

RoadmapSummaryResolver
  reads completed session data
  rejects legacy/non-ElevenLabs stored audio
  rebuilds standard/addiction summary text

EmdrProcessingController
  owns state machine
  awaits narration result before transition
  keeps BLS playback separate

EmdrSessionRepository
  /api/emdr-session/{id}/complete
  processing-state/result persistence
  local fallback persistence
```

Suggested result type for all narration calls:

```dart
enum NarrationResult { completed, cancelled, failed }
```

Do not represent cancellation and failure as the same boolean. The web currently returns `false` for both, which can leave some dynamic flows on the current screen when ElevenLabs fails. In the app:

- `cancelled`: stay in the current state because another user action replaced it;
- `failed`: show a retry/continue-without-audio option according to product policy;
- `completed`: perform the normal transition.

## 10. App implementation checklist

- [ ] Add the six canonical WAV files to Flutter assets and declare them in `pubspec.yaml`.
- [ ] Implement authenticated `/api/voice/tts` and URL extraction.
- [ ] Implement single-active narration, cancellation, pause/resume, and completion callbacks.
- [ ] Implement request cache and in-flight deduplication by namespace + text.
- [ ] Persist and read `roadmapSummaryAudioUrl`, `roadmapSummaryText`, and `roadmapSummaryAudioProvider`.
- [ ] Accept stored summary audio only for provider `elevenlabs` and current copy.
- [ ] Port both standard and addiction summary templates exactly.
- [ ] Port the intro → summary → ready sequence and Start gate.
- [ ] Port all voice-triggered state transitions in the inventory above.
- [ ] Keep BLS endpoint audio independent from narration.
- [ ] Add retry/continue behavior for TTS/network failure.
- [ ] Test background/foreground, interruption, Bluetooth/headphone changes, and screen disposal.

## 11. Minimum acceptance tests

1. Fresh standard session: intro, new summary copy, no duplicate ready line, then Start unlocks.
2. Fresh addiction session: addiction-specific summary copy and correct generated voice.
3. Existing session with `roadmapSummaryAudioProvider = elevenlabs`: stored audio plays.
4. Existing session with missing provider or legacy summary copy: stored audio is ignored and current text is regenerated.
5. Recorded client prompts play in the correct order, especially the two-file `changing` response.
6. Rapid repeated taps do not overlap or duplicate narration.
7. Starting a new prompt cancels the prior one without advancing the prior state.
8. TTS API failure gives a recoverable UI and does not permanently block the session.
9. Pause/resume summary works without restarting from zero.
10. BLS audio never plays while a transition is waiting for mandatory narration to finish.

## 12. Known implementation caveats

- Current web dynamic voice requires a valid token and backend base URL; there is no offline/device-TTS fallback.
- Many web handlers only transition when `playNaturalVoice()` returns `true`. A TTS failure may therefore stall that branch. The app should explicitly handle failure.
- The active hard-coded WAV paths point to `public/voice`, while the detailed audit names `public/client-voice-prompts`. Content is duplicated; choose one canonical app asset set.
- Backend `/api/bilateral/config` may supply `intro`, `calmPlace`, `endSession`, and other instruction URLs. The Flutter implementation must not assume all prompts are bundled assets.
- The summary template exists in both Companion and Simulation fallback logic. Prefer a shared Dart formatter to prevent copy drift.
