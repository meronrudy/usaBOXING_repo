use serde::{Deserialize, Serialize};
#[derive(Debug, Serialize, Deserialize)] pub struct BundleManifest { pub bundle_version: String, pub session_id: String, pub asset_count: usize }
pub fn load_manifest(bytes: &[u8]) -> Result<BundleManifest, serde_json::Error> { serde_json::from_slice(bytes) }
