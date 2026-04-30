use serde::Deserialize;
use std::collections::HashSet;
use std::fs;
use std::path::PathBuf;

#[derive(Deserialize, Debug)]
struct RegistryEntry {
    display_name: String,
    slug: String,
    package_name: String,
    bucket: String,
    family_slug: String,
    sport_code: String,
    discipline_code: String,
    source_url: String,
    source_as_of: String,
    status: String,
}

fn load_registry(path: &str) -> Vec<RegistryEntry> {
    let content = fs::read_to_string(path).expect(&format!("Failed to read {}", path));
    serde_json::from_str(&content).expect(&format!("Failed to parse {}", path))
}

#[test]
fn test_registry_validation() {
    let mut entries = Vec::new();
    entries.extend(load_registry("../../sport-packs/registry/olympic-summer.json"));
    entries.extend(load_registry("../../sport-packs/registry/paralympic-summer.json"));

    let mut slugs = HashSet::new();
    let mut package_names = HashSet::new();
    let mut sport_discipline_pairs = HashSet::new();

    for entry in &entries {
        // every slug is unique
        assert!(slugs.insert(entry.slug.clone()), "Duplicate slug: {}", entry.slug);
        
        // every package name is unique
        assert!(package_names.insert(entry.package_name.clone()), "Duplicate package name: {}", entry.package_name);
        
        // every sport_code/discipline_code pair is unique
        let pair = (entry.sport_code.clone(), entry.discipline_code.clone());
        assert!(sport_discipline_pairs.insert(pair.clone()), "Duplicate sport/discipline pair: {:?}", pair);

        // every registry row has a matching crate path
        let crate_path = PathBuf::from(format!("../../sport-packs/{}/{}", entry.bucket, entry.slug));
        assert!(crate_path.exists(), "Missing crate directory for {}: {:?}", entry.slug, crate_path);
        
        let cargo_toml_path = crate_path.join("Cargo.toml");
        assert!(cargo_toml_path.exists(), "Missing Cargo.toml for {}: {:?}", entry.slug, cargo_toml_path);
        
        let cargo_toml_content = fs::read_to_string(&cargo_toml_path).unwrap();
        assert!(cargo_toml_content.contains(&format!("name = \"{}\"", entry.package_name)), 
            "Cargo.toml for {} does not contain expected package name {}", entry.slug, entry.package_name);
    }

    // every workspace sport-pack has a registry row
    let mut workspace_packs = HashSet::new();
    for bucket in &["olympic", "paralympic"] {
        let dir = fs::read_dir(format!("../../sport-packs/{}", bucket)).unwrap();
        for entry in dir {
            let entry = entry.unwrap();
            if entry.file_type().unwrap().is_dir() {
                workspace_packs.insert(entry.file_name().into_string().unwrap());
            }
        }
    }

    for entry in &entries {
        workspace_packs.remove(&entry.slug);
    }

    assert!(workspace_packs.is_empty(), "Workspace packs without registry entries: {:?}", workspace_packs);
}
