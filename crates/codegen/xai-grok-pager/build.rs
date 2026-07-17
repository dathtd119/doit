//! Pager library version stamp (same rules as `doit` binary build.rs).

use std::path::PathBuf;
use std::process::Command;

fn main() {
    println!("cargo:rerun-if-changed=.git/HEAD");
    println!("cargo:rerun-if-env-changed=GROK_VERSION");
    println!("cargo:rerun-if-env-changed=DOIT_VERSION");

    if let Some(path) = version_file_path() {
        println!("cargo:rerun-if-changed={}", path.display());
    }

    let commit = Command::new("git")
        .args(["rev-parse", "--short", "HEAD"])
        .output()
        .ok()
        .filter(|o| o.status.success())
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .map(|s| s.trim().to_string())
        .unwrap_or_else(|| "unknown".to_string());

    let version = resolve_product_version().unwrap_or_else(|| "0.0.0".to_string());

    println!("cargo:rustc-env=VERSION_WITH_COMMIT={version} ({commit})");
    println!("cargo:rustc-env=GROK_VERSION={version}");
}

fn resolve_product_version() -> Option<String> {
    if let Ok(v) = std::env::var("DOIT_VERSION").or_else(|_| std::env::var("GROK_VERSION")) {
        let t = v.trim();
        if !t.is_empty() {
            return Some(t.to_string());
        }
    }
    read_root_version_file().or_else(|| std::env::var("CARGO_PKG_VERSION").ok())
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
