
// use std::fmt;
use serde::Serialize;
use x11::xinput2;


// fn debug_format<T: fmt::Debug>(object: T) -> String {
//     format!("{:?}", object)
// }

#[repr(i32)]
#[derive(Debug, FromPrimitive, Serialize)]
pub enum DeviceUse {
    XIMasterPointer = xinput2::XIMasterPointer,
    XIMasterKeyboard = xinput2::XIMasterKeyboard,
    XISlavePointer = xinput2::XISlavePointer,
    XISlaveKeyboard = xinput2::XISlaveKeyboard,
    XIFloatingSlave = xinput2::XIFloatingSlave,
}

#[derive(Serialize)]
pub struct DeviceInfo<'h> {
    name: &'h str,
    deviceid: i32,
    deviceuse: DeviceUse,
    attachment: i32,
}
