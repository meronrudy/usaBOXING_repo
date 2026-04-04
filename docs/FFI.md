# FFI

Chosen approach: C ABI plus thin Swift wrapper. Keep exported types small, versioned, and `#[repr(C)]`.
