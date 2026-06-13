// CJS-compatible uuid mock for Jest (uuid v14 is ESM-only)
let _counter = 0;
module.exports = {
  v4: () => `mock-uuid-${++_counter}`,
};
