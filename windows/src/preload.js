const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('widgie', {
  onState: (callback) => {
    const listener = (_event, state) => callback(state);
    ipcRenderer.on('state', listener);
    return () => ipcRenderer.removeListener('state', listener);
  },
});
