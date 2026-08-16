const test = require('node:test');
const assert = require('node:assert/strict');
const { clockAngles } = require('../src/clock-math');

test('hand angles at 3:15:30 match the original ClockMath tests', () => {
  const date = new Date(Date.UTC(2026, 0, 1, 3, 15, 30));
  const utcParts = {
    getHours: () => 3,
    getMinutes: () => 15,
    getSeconds: () => 30,
    getMilliseconds: () => 0,
  };

  const angles = clockAngles(utcParts);
  assert.ok(Math.abs(angles.hour - 97.75) < 0.001);
  assert.ok(Math.abs(angles.minute - 93) < 0.001);
  assert.ok(Math.abs(angles.second - 180) < 0.001);
  assert.ok(date instanceof Date);
});
