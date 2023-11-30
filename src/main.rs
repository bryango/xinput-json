
#[macro_use]
extern crate num_derive;
extern crate num_traits;
extern crate x11;

use x11::{xinput2, xlib};
use std::ffi::CString;
use std::os::raw::c_int;
use std::ptr::{null, null_mut};

mod info;
use crate::info::DeviceInfo;

fn main() {

    // xinput2 example for x11-rs
    // see Pete Hutterer's "XI2 Recipes" blog series,
    // starting at https://who-t.blogspot.com/2009/05/xi2-recipes-part-1.html

    let display = unsafe { xlib::XOpenDisplay(null()) };
    if display == null_mut() {
        panic!("can't open display");
    }

    // query xinput support
    let mut opcode: c_int = 0;
    let mut event: c_int = 0;
    let mut error: c_int = 0;
    let xinput_str = CString::new("XInputExtension").unwrap();
    let xinput_available = unsafe {
        xlib::XQueryExtension(
            display,
            xinput_str.as_ptr(),
            &mut opcode,
            &mut event,
            &mut error,
        )
    };
    if xinput_available == xlib::False {
        panic!("XInput not available")
    }

    let mut xinput_major_ver = xinput2::XI_2_Major;
    let mut xinput_minor_ver = xinput2::XI_2_Minor;
    if unsafe {
        xinput2::XIQueryVersion(
            display,
            &mut xinput_major_ver,
            &mut xinput_minor_ver,
        )
    } != xlib::Success as c_int
    {
        panic!("XInput2 not available");
    }
    eprintln!(
        "XI version available {}.{}",
        xinput_major_ver, xinput_minor_ver
    );

    // dump basic device info as json
    // see `list_xi2` in https://gitlab.freedesktop.org/xorg/app/xinput/-/blob/master/src/list.c
    let mut device_count = 0;
    let all_devices = unsafe { xinput2::XIQueryDevice(
        display,
        xinput2::XIAllDevices,
        &mut device_count
    ) };

    let device_by_number = |i: i32| -> DeviceInfo {
        let device = unsafe { *(all_devices.offset(i as isize)) };
        DeviceInfo::from(device)
    };

    let devices_info: Vec<DeviceInfo>
        = (0..device_count).map(device_by_number).collect();
    let json = serde_json::to_string(&devices_info)
        .expect("failed serializing json");
    println!("{}", json)

}
