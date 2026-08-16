function clockAngles(date) {
  const seconds = date.getSeconds() + date.getMilliseconds() / 1000;
  const minutes = date.getMinutes() + seconds / 60;
  const hours = (date.getHours() % 12) + minutes / 60;
  return {
    hour: hours * 30,
    minute: minutes * 6,
    second: seconds * 6,
  };
}

function buildTicks() {
  const root = document.getElementById('ticks');
  for (let index = 0; index < 60; index += 1) {
    const tick = document.createElement('div');
    tick.className = index % 5 === 0 ? 'tick hour-tick' : 'tick';
    tick.style.transform = `rotate(${index * 6}deg) translateY(-53px)`;
    root.appendChild(tick);
  }
}

function formatTime(date) {
  return date.toLocaleTimeString(undefined, {
    hour: 'numeric',
    minute: '2-digit',
  });
}

const hourHand = document.getElementById('hour');
const minuteHand = document.getElementById('minute');
const secondHand = document.getElementById('second');
const timeLabel = document.getElementById('time');
const tempLabel = document.getElementById('temp');
const widget = document.getElementById('widget');

function paint(date) {
  const angles = clockAngles(date);
  hourHand.style.transform = `rotate(${angles.hour}deg)`;
  minuteHand.style.transform = `rotate(${angles.minute}deg)`;
  secondHand.style.transform = `rotate(${angles.second}deg)`;
  timeLabel.textContent = formatTime(date);
}

function tick() {
  paint(new Date());
  requestAnimationFrame(tick);
}

function applyState(state) {
  widget.classList.toggle('locked', Boolean(state.locked));
  if (state.weather && state.weather.text) {
    tempLabel.textContent = state.weather.text;
  }
}

widget.addEventListener('pointerdown', (event) => {
  if (event.button !== 0 || widget.classList.contains('locked')) return;
  if (!window.widgie || typeof window.widgie.dragStart !== 'function') return;
  widget.setPointerCapture(event.pointerId);
  window.widgie.dragStart(event.screenX, event.screenY);
});

widget.addEventListener('pointermove', (event) => {
  if (!event.buttons || widget.classList.contains('locked')) return;
  if (!window.widgie || typeof window.widgie.dragMove !== 'function') return;
  window.widgie.dragMove(event.screenX, event.screenY);
});

function endDrag() {
  if (window.widgie && typeof window.widgie.dragEnd === 'function') {
    window.widgie.dragEnd();
  }
}

widget.addEventListener('pointerup', endDrag);
widget.addEventListener('pointercancel', endDrag);

buildTicks();
tick();

if (window.widgie && typeof window.widgie.onState === 'function') {
  window.widgie.onState(applyState);
}
