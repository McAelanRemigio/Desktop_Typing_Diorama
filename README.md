# Desktop Companion

A small desktop companion built with Godot that lives on your screen, reacts to keyboard activity, and behaves independently while you work.

The project started as a simple experiment in making a cute desktop character and has grown into a small exploration of autonomous behavior, state machines, animation systems, and reactive interactions.

## Overview

The companion currently consists of a Knight and Princess who have their own movement and behavior systems.

The Knight behaves independently, periodically choosing between idling, walking, and running. When left alone for long enough, he may look around, yawn, or fall asleep.

The Princess follows the Knight around a rotating sphere and has her own stamina and behavior system. When the user is typing, she can become excited and run ahead. As her stamina decreases, she slows down, falls behind, and can eventually become exhausted before recovering and returning to the Knight.

The goal is to make the characters feel like they have small lives of their own rather than simply playing predetermined animations.

## Features

### Knight

The Knight currently supports:

* Idle behavior
* Walking
* Running
* Random direction changes
* Screen boundary detection
* Looking around
* Yawning
* Falling asleep
* Waking up
* Jumping
* Randomized behavior timing
* Animated movement states

The Knight uses a simple state machine:

```text
IDLE
WALKING
RUNNING
SLEEPING
```

His behavior is driven by randomized timers, allowing his actions to vary between sessions.

For example, after a period of inactivity, he may remain idle, start walking, or start running.

While idle, additional behaviors can occur:

```text
IDLE
 ├── Look Around
 ├── Yawn
 └── Sleep
```

## Princess

The Princess has a more reactive behavior system that is influenced by the user's typing activity.

Her current behavior states are:

```text
WITH_KNIGHT
HAPPY_AHEAD
FALLING_BEHIND
EXHAUSTED
RETURNING
```

### Following the Knight

Under normal conditions, the Princess stays near the Knight while the sphere rotates.

Her position is calculated using an angle around the sphere rather than directly moving across the screen.

### Happy Behavior

While the user is typing, the Princess periodically has a chance to become excited.

When this happens, she temporarily runs ahead of the Knight.

```text
Typing detected
      |
      v
WITH_KNIGHT
      |
      v
HAPPY_AHEAD
      |
      v
RETURNING
```

This behavior also consumes stamina more quickly.

### Stamina

The Princess has a maximum stamina of 25.

Normal running gradually drains stamina, while her excited behavior drains it faster.

```text
25  Full stamina
 |
 |
10  Tired threshold
 |
 |
 0  Exhausted
```

Once stamina reaches the tired threshold, she begins falling behind.

As her stamina gets lower, her movement speed decreases.

If her stamina reaches zero, she becomes exhausted and stops moving.

### Recovery

While exhausted, the Princess remains on the ground and gradually recovers stamina.

She must spend a minimum amount of time exhausted before she can return to the Knight.

Once she has recovered enough stamina and is sufficiently close to the Knight, she transitions into the `RETURNING` state.

```text
FALLING_BEHIND
       |
       v
   EXHAUSTED
       |
       v
   RECOVERY
       |
       v
   RETURNING
       |
       v
 WITH_KNIGHT
```

## Typing Activity

A `TypingManager` tracks keyboard activity and exposes a `typing_activity` value to the characters.

This allows the companion to react to what the user is doing without requiring constant manual interaction.

Currently, typing activity affects the Princess by:

* Keeping her active while the user is typing
* Draining stamina
* Giving her opportunities to become excited
* Allowing her to run ahead
* Resetting her idle timer

When typing stops, the Princess can eventually perform an idle jump.

## Jumping

Both characters currently use a simple procedural jump rather than physics.

The jump height is calculated using a sine curve:

```gdscript
height = sin(jump_progress * PI) * max_jump_height
```

This produces a smooth arc while keeping the implementation lightweight.

The current jump duration is 0.8 seconds with a maximum height of 30 pixels.

For the Knight, pressing `Enter` triggers a jump.

## Animation System

The Knight uses Godot's `AnimatedSprite2D` for character animations.

Current animations include:

```text
idle
walk2run
run
lookaround
yawn
go2sleep
sleep
wakeup2idle
jump
```

Special animations are handled separately from normal movement so that an animation such as `lookaround` or `yawn` can finish before the normal movement system resumes control.

For example:

```text
IDLE
  |
  v
lookaround
  |
  v
animation finished
  |
  v
IDLE
```

Sleeping follows a similar sequence:

```text
IDLE
  |
  v
go2sleep
  |
  v
SLEEP
  |
  v
wakeup2idle
  |
  v
IDLE
```

## Orbital Movement

The Princess currently moves around a central sphere using trigonometric positioning.

Her position is calculated from an angle and radius:

```gdscript
var radial_direction := Vector2(
    cos(angle),
    sin(angle)
)

position = radial_direction * radius
```

This allows her to remain attached to the sphere while the world rotates.

It also makes relative behaviors such as running ahead, falling behind, and returning to the Knight easier to control.

## Project Structure

A simplified version of the current scene structure is:

```text
World
├── Sphere
│   └── Princess
├── Knight
└── TypingManager
```

### `knight.gd`

Responsible for:

* Knight movement
* Movement states
* Animation playback
* Random behavior selection
* Idle behavior
* Looking around
* Yawning
* Sleeping
* Waking up
* Jumping
* Screen boundaries
* Direction changes

### `princess.gd`

Responsible for:

* Orbital movement
* Relationship to the Knight
* Behavior states
* Movement states
* Stamina
* Happy behavior
* Falling behind
* Exhaustion
* Recovery
* Returning to the Knight
* Jumping
* Typing activity response

### `TypingManager`

Tracks keyboard input and provides the current typing activity to other systems.

## Controls

| Input   | Action       |
| ------- | ------------ |
| `Enter` | Knight jumps |

The project is designed around minimal direct interaction. Most of the characters' behavior happens autonomously.

## Development Status

This project is currently in development.

### Implemented

* [x] Basic character rendering
* [x] Knight idle behavior
* [x] Knight walking
* [x] Knight running
* [x] Knight direction changes
* [x] Knight screen boundaries
* [x] Knight look-around behavior
* [x] Knight yawning
* [x] Knight sleeping
* [x] Knight waking up
* [x] Knight jumping
* [x] Typing activity detection
* [x] Princess orbital movement
* [x] Princess following the Knight
* [x] Princess happy behavior
* [x] Princess stamina system
* [x] Princess falling-behind behavior
* [x] Princess exhaustion
* [x] Princess stamina recovery
* [x] Princess returning behavior
* [x] Princess jumping

### Planned

* [ ] Additional character interactions
* [ ] More autonomous behaviors
* [ ] Additional animations
* [ ] More characters
* [ ] Desktop/window integration
* [ ] Persistent state
* [ ] Additional reactions to user activity
* [ ] Sound effects
* [ ] Music
* [ ] Visual polish
* [ ] Desktop builds

## Built With

* [Godot 4
* GDScript
* `Node2D`
* `AnimatedSprite2D`
* Custom state machines
* Procedural movement
* Trigonometric positioning
* Randomized behavior systems

## Philosophy

The project is intentionally focused on small behaviors rather than complex gameplay.

The companion shouldn't constantly ask the user what it should do.

Instead, it should occasionally make the user notice it.

A character might:

* Walk somewhere for no apparent reason
* Stop and look around
* Get tired
* Run ahead because it is excited
* Fall asleep when nothing is happening
* Jump when the user interacts with it

None of these behaviors are particularly complicated on their own. The idea is that, together, they can make the characters feel like they are doing something independently of the user.

## Status

Early development.

This is primarily a personal learning project exploring Godot, GDScript, autonomous character behavior, animation systems, and desktop interaction.
