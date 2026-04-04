use runtime_ingest::load_manifest;
#[test] fn parse_manifest() { let data = br#"{"bundle_version":"1","session_id":"sess_001","asset_count":1}"#; let m = load_manifest(data).unwrap(); assert_eq!(m.bundle_version, "1"); }
