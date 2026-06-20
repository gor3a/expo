import base from 'expo-module-scripts/oxlint.config.base';
import { defineConfig } from 'oxlint';

// expo-router-specific overrides on top of the shared base config. This file intentionally omits
// the `@generated` marker so `expo-module configure` won't overwrite it.
export default defineConfig({
  extends: [base],
  rules: {
    // expo-router passes `children` via props in a number of places (notably tests); accepted here.
    'react/no-children-prop': 'off',
  },
});
