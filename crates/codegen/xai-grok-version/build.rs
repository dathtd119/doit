//! Inject product version from repo-root `VERSION` into `GROK_VERSION` rustc-env
//! so `xai_grok_version::VERSION` is Doit-owned, not upstream lockstep Cargo.toml.

use std::path::PathBuf;

fn main() {
    println!("cargo:rerun-if-env-changed=GROK_VERSION");
    println!("cargo:rerun-if-env-changed=DOIT_VERSION");

    if let Some(path) = version_file_path() {
        println!("cargo:rerun-if-changed={}", path.display());
    }

    if let Some(v) = resolve_product_version() {
        println!("cargo:rustc-env=GROK_VERSION={v}");
    }
}

/// Prefer explicit env, then repo-root `VERSION`, else leave unset (crate falls
/// back to `CARGO_PKG_VERSION`).
fn resolve_product_version() -> Option<String> {
    if let Ok(v) = std::env::var("DOIT_VERSION").or_else(|_| std::env::var("GROK_VERSION")) {
        let t = v.trim();
        if !t.is_empty() {
            return Some(t.to_string());
        }
    }
    read_root_version_file()
}

fn version_file_path() -> Option<PathBuf> {
    let manifest = PathBuf::from(std::env::var_os("CARGO_MANIFEST_DIR")?);
    for dir in manifest.ancestors() {
        let candidate = dir.join("VERSION");
        if candidate.is_file() {
            return Some(candidate);
        }
    }
    None
}

fn read_root_version_file() -> Option<String> {
    let path = version_file_path()?;
    let raw = std::fs::read_to_string(path).ok()?;
    // Skip blank lines and `#` comments so VERSION can carry product notes.
    let v = raw
        .lines()
        .map(str::trim)
        .find(|l| !l.is_empty() && !l.starts_with('#'))?;
    if v.is_empty() {
        None
    } else {
        Some(v.to_string())
    }
}
