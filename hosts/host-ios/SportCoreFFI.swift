import Foundation

public enum SportCoreFFI {
    @_silgen_name("sc_version_major") static func sc_version_major() -> Int32
    @_silgen_name("sc_version_minor") static func sc_version_minor() -> Int32
    @_silgen_name("sc_validate_session_bundle") static func sc_validate_session_bundle(_ ptr: UnsafePointer<UInt8>?, _ len: Int) -> Int32

    public static func version() -> String { "\(sc_version_major()).\(sc_version_minor())" }
    public static func validate(bundleData: Data) -> Int32 {
        bundleData.withUnsafeBytes { raw in
            sc_validate_session_bundle(raw.bindMemory(to: UInt8.self).baseAddress, raw.count)
        }
    }
}
