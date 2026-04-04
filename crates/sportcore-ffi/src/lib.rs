use core::ffi::c_int;
#[repr(C)] pub struct ScBuffer { pub ptr: *const u8, pub len: usize }
#[unsafe(no_mangle)] pub extern "C" fn sc_version_major() -> c_int { 0 }
#[unsafe(no_mangle)] pub extern "C" fn sc_version_minor() -> c_int { 1 }
#[unsafe(no_mangle)] pub extern "C" fn sc_validate_session_bundle(_ptr: *const u8, _len: usize) -> c_int { 0 }
#[unsafe(no_mangle)] pub extern "C" fn sc_free_buffer(_buf: ScBuffer) { let _ = _buf; }
