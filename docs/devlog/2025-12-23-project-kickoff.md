# ScummViewer v2 — Project Kickoff

**Date:** 2025-12-23

This marks the beginning of **ScummViewer v2**.

The original ScummViewer started as an experiment: a way to explore SCUMM game
files, learn SwiftUI, and better understand how classic LucasArts adventure games
store and render their assets. Over time, it grew organically — and with that,
it also grew messy.

Version 2 is a deliberate reset.

---

## Why a Rewrite?

The goals of ScummViewer have become clearer over time:

- to *understand* SCUMM, not just display its data,
- to document formats and behavior in a way that others can reuse,
- to keep implementation and explanation closely aligned,
- and to build something maintainable rather than clever.

The original codebase no longer supported these goals well. A rewrite allows
starting with a clean structure, modern SwiftUI patterns, and documentation as a
first-class concern from day one.

---

## Scope of v2

ScummViewer v2 is intentionally narrow in scope:

- It targets **SCUMM v5** initially (Monkey Island 2, Indy, Monkey VGA).
- It focuses on *inspection and visualization*, not editing.
- It prioritizes correctness and clarity over breadth.
- Multi-version support is explicitly **out of scope** for now.

This constraint is important. SCUMM versions differ significantly, and trying to
abstract too early obscures understanding rather than improving it.

---

## Documentation as an Output

One of the core changes in v2 is that documentation is no longer an afterthought.

Alongside the application code, this repository contains:

- a **development log** (`docs/devlog`) documenting discoveries, experiments, and
  decisions,
- a **technical reference** (`docs/scumm`) describing the SCUMM engine itself:
  formats, structures, scripting concepts, and runtime behavior.

The technical reference is a **reconstructed** one, based on reverse-engineering,
existing community knowledge, and hands-on implementation. It is not an original
specification.

The development log captures the path taken to get there.

---

## Current State

At this point, ScummViewer v2 consists of:

- a fresh macOS SwiftUI application project,
- a clean repository structure,
- a clarified scope and documentation strategy.

No SCUMM decoding is implemented yet. That is intentional.

The first milestones will focus on file access, browsing, and building a solid
foundation for inspecting game resources.

---

## Next Steps

The immediate next steps are:

1. Implement basic file/folder opening using macOS sandboxed file access.
2. Display a navigable view of SCUMM game files.
3. Begin documenting the SCUMM v5 disk and resource layout in `docs/scumm`.

From there, decoding and rendering will be added incrementally, guided by
documentation rather than the other way around.

---

This devlog is not meant to be exhaustive or polished. It exists to preserve
context, reasoning, and intent — for future contributors, and for myself when
returning to this project later.

