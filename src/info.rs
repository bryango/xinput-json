
// use std::fmt;
use std::ffi::CString;
use serde::Serialize;
use x11::xinput2::{self, XIDeviceInfo};
use num_traits::FromPrimitive;


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
pub struct DeviceInfo {
    pub name: String,
    pub deviceid: i32,
    pub deviceuse: DeviceUse,
    pub attachment: i32,
}

impl From<XIDeviceInfo> for DeviceInfo {
    fn from(device: XIDeviceInfo) -> Self {
        let name = unsafe { CString::from_raw(device.name) };
        let name = String::from(name.to_str().unwrap());
        Self {
            name: name,
            deviceid: device.deviceid,
            deviceuse: DeviceUse::from_i32(device._use).unwrap(),
            attachment: device.attachment,
        }
    }
}
