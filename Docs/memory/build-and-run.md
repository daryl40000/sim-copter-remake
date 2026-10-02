# Building the C++ — always use RebuildUnrealCpp.bat

To compile, run `RebuildUnrealCpp.bat` at the repo root. Do **not** invoke
`C:\GameDev\UE_5.8\Engine\Build\BatchFiles\Build.bat` directly.

**Why:** the wrapper pins the engine root, the project file, the
`SimCopterRemakeEditor Win64 Development` target and — the part that matters —
`-NoLiveCoding`. A Live Coding session holding `UnrealEditor-SimCopterRemake.dll` makes a raw
Build.bat run fail to link, or silently hot-patch instead of relinking, so you end up testing
stale code. James rejected a direct Build.bat invocation and asked for the wrapper.

**How to run it non-interactively:** the script ends in `pause`, so feed it empty stdin or it
hangs waiting for a keypress. From PowerShell:

```powershell
cmd /c "S:\Repos\sim-copter-remake\RebuildUnrealCpp.bat < nul" 2>&1 | Select-Object -Last 35
```

(PowerShell 5.1 reserves bare `<`, hence the redirect living inside the `cmd /c` string.)
A clean build is ~60 s and ends with `Result: Succeeded`.

Launching the built game to verify a change: see `simcopter-ingame-verification` notes —
`-game -windowed`, then drive and screenshot the Slate UI from PowerShell.
Long build logs belong in `Docs/scratchpad/` (see `agent-workspace-conventions.md`).

## Linux

Use `RebuildUnrealCpp.sh` at the repo root. It calls the engine's
`Engine/Build/BatchFiles/Linux/Build.sh` for `SimCopterRemakeEditor Linux Development`
(or `SimCopterRemake Linux Shipping` when passed `Shipping`). Same `-NoLiveCoding` pin as
the `.bat`.

The engine is Unreal **5.8 for Linux**, not the Windows tree. Point the script at it with
`UE_ROOT` if it is not under `~/UnrealEngine` or `~/UE_5.8`:

```bash
UE_ROOT="$HOME/UnrealEngine" ./RebuildUnrealCpp.sh
```

DLSS, Streamline frame generation and Reflex are optional and `Win64`-only in the `.uproject`.
The C++ already compiles them out when those modules are not linked. CelestialVault and
DaySequence ship inside the 5.8 engine (`Engine/Plugins/Experimental`).

On Wayland with an NVIDIA card, start the editor with `SDL_VIDEODRIVER=x11`. If the view is
black, add `-noraytracing` for that launch. Do not turn hardware ray tracing off in
`DefaultEngine.ini`: that file is shared with the Windows build.

Linux filesystems are case-sensitive. The 1996 disc spells `BMP/`, `GEO/`, `X/` and upper-case
sound names, and a copy of the original data is often entirely lower case (`bmp/sim3d.bmp`).
Readers go through `SimCopterOriginalGame::ResolveExistingPath`, which keeps an exact match when
one exists and otherwise finds the same folder or file ignoring letter case. Do not hard-code
`FPaths::Combine` plus `FileExists` for those trees: the city then rebuilds with a brown ground
and a white box for the helicopter, because the GEO meshes and the runtime BMP decode never open.
