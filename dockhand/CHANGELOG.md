## 1.0.0

- Initial release
- Dockhand Docker management UI wrapped as a Home Assistant app
- Ingress support for sidebar access
- Docker socket passthrough (requires Protection Mode disabled)
- SQLite-backed persistent storage
- Known issue: Home Assistant ingress can log transient stream disconnect noise
  (`net::ERR_FAILED`, `Cannot write to closing transport`) during page navigation;
  this is usually benign when streams reconnect and UI remains responsive
