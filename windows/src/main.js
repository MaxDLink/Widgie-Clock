const { app, BrowserWindow, Tray, Menu, screen, nativeImage } = require('electron');
const fs = require('fs');
const path = require('path');

const WIDTH = 148;
const HEIGHT = 186;
const WEATHER_MS = 5 * 60 * 1000;
const SETTINGS_DEFAULTS = {
  locked: true,
  useFahrenheit: true,
  openAtLogin: false,
  x: null,
  y: null,
};

let win;
let tray;
let weatherTimer;
let settings = { ...SETTINGS_DEFAULTS };
let weather = { text: '—', city: '', ok: false };

function settingsPath() {
  return path.join(app.getPath('userData'), 'settings.json');
}

function loadSettings() {
  try {
    settings = { ...SETTINGS_DEFAULTS, ...JSON.parse(fs.readFileSync(settingsPath(), 'utf8')) };
  } catch {
    settings = { ...SETTINGS_DEFAULTS };
  }
}

function saveSettings() {
  fs.mkdirSync(path.dirname(settingsPath()), { recursive: true });
  fs.writeFileSync(settingsPath(), JSON.stringify(settings, null, 2));
}

function defaultPosition() {
  const area = screen.getPrimaryDisplay().workArea;
  return {
    x: Math.round(area.x + area.width - WIDTH - 24),
    y: Math.round(area.y + 24),
  };
}

function publicState() {
  return {
    locked: settings.locked,
    useFahrenheit: settings.useFahrenheit,
    weather,
  };
}

function sendState() {
  if (win && !win.isDestroyed()) {
    win.webContents.send('state', publicState());
  }
}

async function fitLayoutToCss() {
  if (!win || win.isDestroyed()) return;
  const info = await win.webContents.executeJavaScript(
    '({ dpr: window.devicePixelRatio, vw: window.innerWidth, vh: window.innerHeight })'
  );
  if (!info) return;

  const dpr = Number(info.dpr) || 1;
  const needsCssRoom = info.vw < WIDTH - 1 || info.vh < HEIGHT - 1;
  const needsBackingStore = dpr > 1.01 && (win.getBounds().width < WIDTH * dpr - 2);
  if (!needsCssRoom && !needsBackingStore) {
    return;
  }

  const factor = needsBackingStore ? dpr : Math.max(WIDTH / info.vw, HEIGHT / info.vh);
  const bounds = win.getBounds();
  const width = Math.ceil(bounds.width * factor);
  const height = Math.ceil(bounds.height * factor);
  const area = screen.getDisplayMatching(bounds).workArea;
  let { x, y } = bounds;
  if (x + width > area.x + area.width) {
    x = area.x + area.width - width - 8;
  }
  if (y + height > area.y + area.height) {
    y = area.y + area.height - height - 8;
  }
  win.setBounds({ x, y, width, height });
}

function applyLock() {
  if (!win || win.isDestroyed()) return;
  win.setIgnoreMouseEvents(Boolean(settings.locked), { forward: true });
  sendState();
}

function createWindow() {
  const pos =
    Number.isFinite(settings.x) && Number.isFinite(settings.y)
      ? { x: settings.x, y: settings.y }
      : defaultPosition();

  win = new BrowserWindow({
    width: WIDTH,
    height: HEIGHT,
    x: pos.x,
    y: pos.y,
    frame: false,
    transparent: false,
    alwaysOnTop: true,
    skipTaskbar: true,
    resizable: false,
    maximizable: false,
    minimizable: false,
    fullscreenable: false,
    hasShadow: true,
    roundedCorners: true,
    thickFrame: false,
    backgroundColor: '#161616',
    show: false,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  win.setAlwaysOnTop(true, 'screen-saver');
  win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });
  win.loadFile(path.join(__dirname, 'renderer', 'index.html'));

  win.webContents.on('did-finish-load', async () => {
    await fitLayoutToCss();
    applyLock();
    if (!win.isVisible()) {
      win.show();
    }
    win.setAlwaysOnTop(true, 'screen-saver');
  });

  win.on('moved', () => {
    if (!win || win.isDestroyed()) return;
    const [x, y] = win.getPosition();
    settings.x = x;
    settings.y = y;
    saveSettings();
  });
}

function trayIcon() {
  const iconFile = path.join(__dirname, '..', 'assets', 'icon.jpg');
  const image = nativeImage.createFromPath(iconFile);
  return image.isEmpty() ? nativeImage.createEmpty() : image.resize({ width: 16, height: 16 });
}

function rebuildTray() {
  if (!tray) {
    tray = new Tray(trayIcon());
    tray.setToolTip('Widgie Clock');
  }

  const place = weather.city ? `${weather.city}  ·  ${weather.text}` : weather.text;
  const template = [
    { label: 'Widgie Clock', enabled: false },
    { label: place, enabled: false },
    { type: 'separator' },
    {
      label: settings.locked ? 'Unlock to Move' : 'Enable Click-Through',
      click: () => {
        settings.locked = !settings.locked;
        saveSettings();
        applyLock();
        rebuildTray();
      },
    },
    {
      label: settings.useFahrenheit ? 'Switch to Celsius' : 'Switch to Fahrenheit',
      click: async () => {
        settings.useFahrenheit = !settings.useFahrenheit;
        saveSettings();
        await refreshWeather();
      },
    },
    {
      label: 'Refresh Weather',
      click: () => {
        refreshWeather();
      },
    },
    { type: 'separator' },
    {
      label: 'Start at Login',
      type: 'checkbox',
      checked: Boolean(settings.openAtLogin),
      click: (item) => {
        settings.openAtLogin = item.checked;
        app.setLoginItemSettings({ openAtLogin: item.checked });
        saveSettings();
      },
    },
    { type: 'separator' },
    {
      label: 'Quit Widgie Clock',
      click: () => app.quit(),
    },
  ];

  tray.setContextMenu(Menu.buildFromTemplate(template));
}

async function refreshWeather() {
  try {
    const locRes = await fetch('https://ipwho.is/');
    const loc = await locRes.json();
    if (!loc.success) {
      throw new Error('Could not resolve location');
    }

    const unit = settings.useFahrenheit ? 'fahrenheit' : 'celsius';
    const wxUrl =
      `https://api.open-meteo.com/v1/forecast?latitude=${loc.latitude}` +
      `&longitude=${loc.longitude}&current=temperature_2m&temperature_unit=${unit}`;
    const wx = await (await fetch(wxUrl)).json();
    const temp = Math.round(wx.current.temperature_2m);

    weather = {
      text: `${temp}°`,
      city: loc.city || '',
      ok: true,
    };
  } catch {
    weather = {
      text: weather.ok ? weather.text : '—',
      city: weather.city || '',
      ok: false,
    };
  }

  sendState();
  rebuildTray();
}

function startWeatherLoop() {
  refreshWeather();
  clearInterval(weatherTimer);
  weatherTimer = setInterval(refreshWeather, WEATHER_MS);
}

app.commandLine.appendSwitch('enable-transparent-visuals');

const gotLock = app.requestSingleInstanceLock();
if (!gotLock) {
  app.quit();
} else {
  app.on('second-instance', () => {
    if (win && !win.isDestroyed()) {
      win.showInactive();
    }
  });

  app.whenReady().then(() => {
    app.setName('Widgie Clock');
    loadSettings();
    app.setLoginItemSettings({ openAtLogin: Boolean(settings.openAtLogin) });
    createWindow();
    rebuildTray();
    startWeatherLoop();
  });
}

app.on('window-all-closed', (event) => {
  event.preventDefault();
});
