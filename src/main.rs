use std::io::Error;

use log::{error, info};
use niri_ipc::{Event, Response, socket::Socket};
use zbus::blocking::Connection;

#[zbus::proxy(
    default_service = "com.system76.Scheduler",
    interface = "com.system76.Scheduler",
    default_path = "/com/system76/Scheduler"
)]
trait System76Scheduler {
    fn set_foreground_process(&self, pid: u32) -> zbus::Result<()>;
}

fn main() -> std::io::Result<()> {
    colog::init();

    let mut socket = Socket::connect()?;

    let conn = Connection::system().map_err(Error::other)?;

    let proxy = System76SchedulerProxyBlocking::new(&conn).map_err(Error::other)?;

    let reply = socket.send(niri_ipc::Request::EventStream)?;

    if !matches!(reply, Ok(Response::Handled)) {
        error!("Niri didn't handle event stream request: {reply:?}");
    }
    let mut windows = Vec::new();

    let mut read_event = socket.read_events();

    while let Ok(event) = read_event() {
        match event {
            Event::WindowsChanged { windows: _windows } => windows = _windows,
            Event::WindowFocusChanged { id: Some(id) } => {
                let window = windows.iter().find(|window| window.id == id);

                if let Some(window) = window {
                    if let Some(pid) = window.pid {
                        if let Err(why) = proxy.set_foreground_process(pid as u32) {
                            error!("Failed to set foreground process PID: {why}");
                        };
                        info!(
                            "Set window {:?} with PID {} as the foreground process",
                            window.title, pid
                        );
                    }
                }
            }

            _ => (),
        }
    }

    Ok(())
}
