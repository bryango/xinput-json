
use std::ffi::CString;
use serde::Serialize;
use x11::xinput2::{self, XIDeviceInfo};
use num_traits::FromPrimitive;


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
    name: String,
    id: i32,
    r#use: Option<DeviceUse>,
    attachment: i32,
    enabled: bool,
}

impl From<XIDeviceInfo> for DeviceInfo {
    fn from(device: XIDeviceInfo) -> Self {
        let name = unsafe { CString::from_raw(device.name) };
        let name = String::from(
            name.to_str().expect("the device name should be a valid string")
        );
        Self {
            name: name,
            id: device.deviceid,
            r#use: DeviceUse::from_i32(device._use),
            attachment: device.attachment,
            enabled: device.enabled != 0,
        }
    }
}
