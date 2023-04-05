# Keccak_exercises
Make tests under `exercises/ExerciseN.test.ts` passe by modifying the `exercises.cairo` contract under `contracts/cairo/exercises.cairo`.

There are three muted functions, unmute and complete them before compilation.
- Compile your contract using `yarn compile`.
- Run `yarn test:exerciseN` with `N` the exercises number you want to run.

Take your time, try to use `abi.encodePacked(...)` to see when you need right padding. You can modify `example.sol` and use the helper function `getAbiEncodePacked` for that.

The solutions for those exercises are under `contracts/cairo/solutions.cairo`, you can also write your own tests.