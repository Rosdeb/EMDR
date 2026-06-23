Goal

Make the Flutter BLS session use the animation timeline as the single source of truth, exactly like the web implementation.

The visual movement must drive all timing. Audio must only respond to animation endpoint events. Eliminate any possibility of animation/audio drift across slow, medium, and fast speeds.

Phase 1 – Refactor Architecture

Split the current simulation_screen.dart responsibilities into three independent classes.

1. BilateralAnimationController

Responsible only for:

AnimationController
Direction
Position calculation
Endpoint detection
Pause/Resume state
Emits endpoint events

Example API

start()
pause()
resume()
stop()

Stream<EndpointEvent>

No audio code.

No session code.

No timers.

2. BilateralAudioSync

Responsible only for:

Loading sound
Tone profile generation
Asset playback
Stereo panning
Left/right hit playback
Continuous sound fallback

Example API

playLeft()
playRight()
startContinuous()
stop()
pause()
resume()

Never owns timing.

Never owns animation.

Never starts timers.

3. BilateralSessionOrchestrator

Responsible only for

Sets
Session timer
Intro
Check-in
VOC
SUDS
Body scan
Calm place
Completion

It subscribes to

animation.endpointStream

and advances the session.

Phase 2 – Make Animation the Master Clock

Animation must become the only timing source.

Current

Animation
↓

Audio
↓

Timer

↓

Reverse

Replace with

Animation

↓

Endpoint detected

↓

Fire EndpointEvent

↓

Audio plays

↓

Reverse animation

Audio must never control movement.

Movement controls everything.

Phase 3 – Replace AnimationStatus Timing

Remove

AnimationStatus.completed

AnimationStatus.dismissed

Instead monitor

_controller.value

Example

if(value>=0.995&&!rightPlayed)

emit RightEndpoint

if(value<=0.005&&!leftPlayed)

emit LeftEndpoint

Reason

AnimationStatus callbacks are slightly delayed on some devices.

Controller value is frame accurate.

Phase 4 – Remove Audio Playback Rate Logic

Delete

player.setPlaybackRate(...)

Speed presets

Slow

0.8 sec

Medium

0.5 sec

Fast

0.3 sec

must only change

Animation duration

Never

Audio speed
Phase 5 – Improve Audio Playback

Current

stop()

resume()

Replace with preloaded playback.

Players should remain loaded.

Only trigger playback.

Avoid recreating sources every endpoint.

Phase 6 – Endpoint Audio

Every movement should fire audio exactly once.

Left

↓

playLeft()

↓

mark fired

↓

ignore until movement reverses

Same for Right.

Never allow duplicate hits.

Phase 7 – Pause / Resume

When paused store

controller.value

direction

remaining duration

current side

left fired

right fired

current set

current phase

Resume from

controller.forward(from:savedValue)

or

controller.reverse(from:savedValue)

Never restart from zero.

Phase 8 – Session Flow

Session phases remain independent

Intro

↓

Start

↓

Playing

↓

Check-in

↓

SUDS

↓

VOC

↓

Body Scan

↓

Calm Place

↓

End

The BLS animation must not know anything about these phases.

Phase 9 – Speed Handling

Keep

class BlsSpeedPresets{

slow=0.8

medium=0.5

fast=0.3

}

Do not change.

Only

AnimationController.duration

changes.

Phase 10 – Audio Modes

Support two modes

Tone Profile
Generate left tone

Generate right tone

Play endpoint hit
Audio File
Preload

Play left

Play right

Stereo balance

Fallback

If analysis fails

Simple left/right panned playback

Session must continue.

Phase 11 – Remove Timing Drift

There must be

❌ No Timer.periodic for synchronization

❌ No Future.delayed used as the master clock

❌ No playbackRate synchronization

Only

AnimationController

↓

Endpoint Event

↓

Audio
Phase 12 – Testing

Verify

✅ Horizontal

✅ Vertical

✅ Diagonal

✅ Slow

✅ Medium

✅ Fast

✅ Pause

✅ Resume

✅ Tone profiles

✅ Asset sounds

✅ Network sounds

✅ Long sessions (60–90 minutes)

Ensure animation and audio never drift.

Expected Result

After implementing the above:

Animation becomes the single source of truth.
Audio is triggered exactly at the animation endpoints.
Slow, medium, and fast speeds stay synchronized without changing audio playback speed.
Pause/resume restores the exact position and phase.
The Flutter implementation behaves much closer to the web implementation and remains stable over long sessions.