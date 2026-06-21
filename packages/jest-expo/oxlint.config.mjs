import base from 'expo-module-scripts/oxlint.config.base';
import { defineConfig } from 'oxlint';

export default defineConfig({
  extends: [base],
  // `src/index.d.ts` mixes an ambient `export =` with named exports, which tsc accepts but oxlint's
  // parser reports as a false-positive (TS 2309). TypeScript parser diagnostics can't be silenced
  // with a disable comment, so we ignore the file.
  ignorePatterns: ['src/index.d.ts'],
});
