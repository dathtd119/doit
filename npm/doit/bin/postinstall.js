#!/usr/bin/env node
// Postinstall: copy native binary from optional platform package into
// ~/.local/share/doit/bin/ with versioned filenames + symlink/copy.
//
// Layout (CFG-DOIT share dir, not ~/.grok):
//   Unix:    doit-<version>  +  doit  (symlink)
//   Windows: doit-<version>.exe  +  doit.exe  (copy)
//
// Binaries ship brotli-compressed (.br) in platform packages (~npm 200 MB limit).
const path = require('path');
const fs = require('fs');
const os = require('os');
const zlib = require('zlib');

const pkgName = '@dathtd119/doit';
const CANONICAL_DIR = path.join(
  process.env.XDG_DATA_HOME || path.join(os.homedir(), '.local', 'share'),
  'doit',
  'bin',
);

const key = `${process.platform}-${process.arch}`;
const SUPPORTED = new Set([
  'darwin-arm64',
  'darwin-x64',
  'linux-x64',
  'linux-arm64',
  'win32-x64',
  'win32-arm64',
]);

if (!SUPPORTED.has(key)) {
  console.error(`${pkgName}: unsupported platform ${key}`);
  process.exit(0);
}

function resolvePlatformPackageDir() {
  const platformPkg = `@dathtd119/doit-${key}`;
  try {
    return path.dirname(require.resolve(`${platformPkg}/package.json`));
  } catch {
    return null;
  }
}

let version;
try {
  version = require('../package.json').version;
} catch {
  /* ignore */
}
if (!version) {
  console.error(`${pkgName}: unable to determine version`);
  process.exit(0);
}

const IS_WINDOWS = process.platform === 'win32';
const EXE = IS_WINDOWS ? '.exe' : '';

fs.mkdirSync(CANONICAL_DIR, { recursive: true });

function installBinary(binName, sourceDir) {
  const brPath = path.join(sourceDir, 'bin', `${binName}${EXE}.br`);
  const rawPath = path.join(sourceDir, 'bin', `${binName}${EXE}`);
  let vendoredBinPath;
  if (fs.existsSync(brPath)) {
    const compressed = fs.readFileSync(brPath);
    const decompressed = zlib.brotliDecompressSync(compressed);
    vendoredBinPath = rawPath;
    fs.writeFileSync(vendoredBinPath, decompressed);
    if (!IS_WINDOWS) fs.chmodSync(vendoredBinPath, 0o755);
    try {
      fs.unlinkSync(brPath);
    } catch {
      /* ignore */
    }
  } else if (fs.existsSync(rawPath)) {
    vendoredBinPath = rawPath;
  } else {
    console.error(`${pkgName}: missing binary at ${brPath}`);
    return false;
  }

  const versionedName = `${binName}-${version}${EXE}`;
  const versionedPath = path.join(CANONICAL_DIR, versionedName);
  const canonicalName = `${binName}${EXE}`;
  const canonicalPath = path.join(CANONICAL_DIR, canonicalName);

  if (!fs.existsSync(versionedPath)) {
    const tmpPath = `${versionedPath}.tmp.${process.pid}`;
    try {
      fs.copyFileSync(vendoredBinPath, tmpPath);
      if (!IS_WINDOWS) fs.chmodSync(tmpPath, 0o755);
      fs.renameSync(tmpPath, versionedPath);
    } finally {
      try {
        fs.unlinkSync(tmpPath);
      } catch {
        /* ignore */
      }
    }
  }

  if (IS_WINDOWS) {
    const oldPath = `${canonicalPath}.old`;
    try {
      fs.unlinkSync(oldPath);
    } catch {
      /* ignore */
    }
    try {
      try {
        fs.unlinkSync(canonicalPath);
      } catch {
        /* ignore */
      }
      fs.copyFileSync(versionedPath, canonicalPath);
    } catch (e) {
      try {
        fs.renameSync(canonicalPath, oldPath);
        try {
          fs.copyFileSync(versionedPath, canonicalPath);
        } catch (copyErr) {
          try {
            fs.renameSync(oldPath, canonicalPath);
          } catch {
            /* ignore */
          }
          throw copyErr;
        }
      } catch (e2) {
        console.error(
          `${pkgName}: failed to update ${canonicalPath}: ${e2.message}`,
        );
        console.error('Close all running doit processes and try again.');
        return false;
      }
    }
  } else {
    const tmpLink = `${canonicalPath}.link.${process.pid}`;
    try {
      fs.unlinkSync(tmpLink);
    } catch {
      /* ignore */
    }
    fs.symlinkSync(versionedName, tmpLink);
    fs.renameSync(tmpLink, canonicalPath);
  }

  console.log(
    `${binName} ${version} installed to ${canonicalPath} -> ${versionedName}`,
  );
  return true;
}

function cleanupOldVersions(binName) {
  try {
    const prefix = `${binName}-`;
    const currentVersioned = `${binName}-${version}${EXE}`;
    const entries = fs.readdirSync(CANONICAL_DIR);
    const versionedBinaries = entries
      .filter((e) => {
        if (!e.startsWith(prefix)) return false;
        if (e.includes('.tmp.') || e.includes('.link.')) return false;
        if (e === currentVersioned) return false;
        const suffix = e.slice(prefix.length);
        return /^\d/.test(suffix);
      })
      .sort((a, b) => {
        const pa = a.slice(prefix.length).split('.').map(Number);
        const pb = b.slice(prefix.length).split('.').map(Number);
        for (let i = 0; i < 3; i++) {
          if ((pa[i] || 0) !== (pb[i] || 0)) {
            return (pb[i] || 0) - (pa[i] || 0);
          }
        }
        return 0;
      });
    for (const old of versionedBinaries.slice(1)) {
      try {
        fs.unlinkSync(path.join(CANONICAL_DIR, old));
      } catch {
        /* ignore */
      }
    }
  } catch {
    /* ignore */
  }
}

const platformDir = resolvePlatformPackageDir();
if (!platformDir) {
  console.error(
    `${pkgName}: platform package @dathtd119/doit-${key} not installed.`,
  );
  console.error(
    '  Usually --no-optional was used, or optional install failed.',
  );
  console.error(`  Try: npm install -g ${pkgName}`);
  process.exit(0);
}

installBinary('doit', platformDir);
cleanupOldVersions('doit');
