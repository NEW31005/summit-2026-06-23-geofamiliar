# Mari Operator Guardrails

This file exists because the GeoFamiliar phase work hit repeated tool-level
`{"detail":"Bad Request"}` interruptions. The app was not the cause; malformed
Codex tool usage was.

## Fixed Rules

1. Use only tool names exposed in the current session.
   - Use `functions.exec_command` for shell work.
   - Do not call `functions.shell_command`.
2. Avoid `multi_tool_use.parallel` during the 1 -> 3 -> 2 rebuild unless there
   is a clear reason and every target tool name is verified.
3. Do not chain validation commands with `;` or `&&`.
   - Run `flutter analyze`, `flutter test`, and `flutter build web` as separate
     calls so a failure stops at the failing step.
4. After every failed command, fix the failing cause before running the next
   validation command.
5. Before browser/Claude review work, finish local verification first.

## Current Build Order

Phase order is fixed: 1 -> 3 -> 2.

Phase 1 gate: app starts on the map, GPS/current-position loop exists, mesh
spots are already on the map, and entering a spot captures a familiar without
requiring a tap.
