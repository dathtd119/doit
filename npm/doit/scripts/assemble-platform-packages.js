#!/usr/bin/env node
// Assemble six per-platform npm packages before `npm publish`.
//
// For each (os, arch):
//   1. Brotli-compress the release binary into npm/doit-<os>-<arch>/bin/doit[.exe].br
//   2. Stamp package version to match meta package + root VERSION
//   3. Copy THIRD-PARTY-NOTICES
//
// Source binaries: set DOIT_<PLATFORM> env vars (CI) or pass --from-archives DIR
// containing GitHub Release assets:
//   doit-<version>-x86_64-unknown-linux-gnu.tar.gz
//   …
//
// Why brotli: npm ~200 MB tarball limit; raw doit is ~150–190 MB.
const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const { execSync } = require('child_process');
const zlib = require('zlib');

const brotliCompress = promisify(zlib.brotliCompress);

const npmRoot = path.resolve(__dirname, '..', '..');
const repoRoot = path.resolve(npmRoot, '..');
const META_PKG_JSON = path.join(npmRoot, 'doit', 'package.json');

function readProductVersion() {
  const versionFile = path.join(repoRoot, 'VERSION');
  if (fs.existsSync(versionFile)) {
    const line = fs
      .readFileSync(versionFile, 'utf8')
      .split('\n')
      .map((l) => l.trim())
      .find((l) => l && !l.startsWith('#'));
    if (line) return line;
  }
  return JSON.parse(fs.readFileSync(META_PKG_JSON, 'utf8')).version;
}

const VERSION = process.env.DOIT_VERSION || readProductVersion();
const NOTICES_SOURCE = path.join(repoRoot, 'THIRD-PARTY-NOTICES');
const NOTICES_NAME = 'THIRD-PARTY-NOTICES';

// npm platform/arch → rustc target triple used by release.yml archives
const TARGETS = [
  {
    platform: 'darwin',
    arch: 'arm64',
    binName: 'doit',
    rustTarget: 'aarch64-apple-darwin',
    envVar: 'DOIT_DARWIN_ARM64',
    archiveExt: 'tar.gz',
  },
  {
    platform: 'darwin',
    arch: 'x64',
    binName: 'doit',
    rustTarget: 'x86_64-apple-darwin',
    envVar: 'DOIT_DARWIN_X64',
    archiveExt: 'tar.gz',
  },
  {
    platform: 'linux',
    arch: 'x64',
    binName: 'doit',
    rustTarget: 'x86_64-unknown-linux-gnu',
    envVar: 'DOIT_LINUX_X64',
    archiveExt: 'tar.gz',
  },
  {
    platform: 'linux',
    arch: 'arm64',
    binName: 'doit',
    rustTarget: 'aarch64-unknown-linux-gnu',
    envVar: 'DOIT_LINUX_ARM64',
    archiveExt: 'tar.gz',
  },
  {
    platform: 'win32',
    arch: 'x64',
    binName: 'doit.exe',
    rustTarget: 'x86_64-pc-windows-msvc',
    envVar: 'DOIT_WIN32_X64',
    archiveExt: 'zip',
  },
  {
    platform: 'win32',
    arch: 'arm64',
    binName: 'doit.exe',
    rustTarget: 'aarch64-pc-windows-msvc',
    envVar: 'DOIT_WIN32_ARM64',
    archiveExt: 'zip',
  },
];

function ensureDir(p) {
  fs.mkdirSync(path.dirname(p), { recursive: true });
}

function parseArgs(argv) {
  const out = { fromArchives: null };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--from-archives' && argv[i + 1]) {
      out.fromArchives = path.resolve(argv[++i]);
    }
  }
  return out;
}

function extractBinaryFromArchive(archivePath, binName, destDir) {
  fs.mkdirSync(destDir, { recursive: true });
  const stage = fs.mkdtempSync(path.join(destDir, '.extract-'));
  try {
    if (archivePath.endsWith('.zip')) {
      execSync(`unzip -qo ${JSON.stringify(archivePath)} -d ${JSON.stringify(stage)}`, {
        stdio: 'inherit',
      });
    } else {
      execSync(`tar -xzf ${JSON.stringify(archivePath)} -C ${JSON.stringify(stage)}`, {
        stdio: 'inherit',
      });
    }
    // Find binary (archive stages flat: doit / doit.exe)
    const candidates = [
      path.join(stage, binName),
      path.join(stage, 'bin', binName),
    ];
    let found = null;
    for (const c of candidates) {
      if (fs.existsSync(c)) {
        found = c;
        break;
      }
    }
    if (!found) {
      // walk one level
      for (const ent of fs.readdirSync(stage)) {
        const p = path.join(stage, ent, binName);
        if (fs.existsSync(p)) {
          found = p;
          break;
        }
        if (ent === binName) {
          found = path.join(stage, ent);
          break;
        }
      }
    }
    if (!found) {
      throw new Error(`binary ${binName} not found in ${archivePath}`);
    }
    const out = path.join(destDir, binName);
    fs.copyFileSync(found, out);
    return out;
  } finally {
    fs.rmSync(stage, { recursive: true, force: true });
  }
}

function resolveSource(target, fromArchives) {
  if (process.env[target.envVar] && fs.existsSync(process.env[target.envVar])) {
    return process.env[target.envVar];
  }
  if (fromArchives) {
    const base = `doit-${VERSION}-${target.rustTarget}.${target.archiveExt}`;
    const archivePath = path.join(fromArchives, base);
    if (!fs.existsSync(archivePath)) {
      // also try without nested dirs (merge-multiple download)
      const alt = fs
        .readdirSync(fromArchives, { withFileTypes: true })
        .filter((d) => d.isFile() && d.name === base)
        .map((d) => path.join(fromArchives, d.name))[0];
      if (!alt) {
        throw new Error(`missing archive ${base} under ${fromArchives}`);
      }
      return extractBinaryFromArchive(alt, target.binName, path.join(fromArchives, `_bin_${target.rustTarget}`));
    }
    return extractBinaryFromArchive(
      archivePath,
      target.binName,
      path.join(fromArchives, `_bin_${target.rustTarget}`),
    );
  }
  // Local cargo default
  const local = path.join(
    repoRoot,
    'target',
    target.rustTarget,
    'release',
    target.binName,
  );
  if (fs.existsSync(local)) return local;
  const host = path.join(repoRoot, 'target', 'release', target.binName);
  if (fs.existsSync(host) && target.platform === process.platform) return host;
  return null;
}

async function packPlatform(target, fromArchives) {
  const pkgDir = path.join(npmRoot, `doit-${target.platform}-${target.arch}`);
  const pkgJsonPath = path.join(pkgDir, 'package.json');
  if (!fs.existsSync(pkgJsonPath)) {
    console.error(`[assemble] Missing package at ${pkgDir}`);
    return false;
  }

  let source;
  try {
    source = resolveSource(target, fromArchives);
  } catch (e) {
    console.error(`[assemble] ${target.platform}-${target.arch}: ${e.message}`);
    return false;
  }
  if (!source || !fs.existsSync(source)) {
    console.error(
      `[assemble] Missing binary for ${target.platform}-${target.arch}`,
    );
    console.error(`            Set ${target.envVar} or use --from-archives DIR`);
    return false;
  }

  const subPkg = JSON.parse(fs.readFileSync(pkgJsonPath, 'utf8'));
  subPkg.version = VERSION;
  fs.writeFileSync(pkgJsonPath, `${JSON.stringify(subPkg, null, 2)}\n`);

  if (fs.existsSync(NOTICES_SOURCE)) {
    fs.copyFileSync(NOTICES_SOURCE, path.join(pkgDir, NOTICES_NAME));
  }

  const outBr = path.join(pkgDir, 'bin', `${target.binName}.br`);
  ensureDir(outBr);
  // Drop raw binaries from package dir so only .br ships
  const rawOut = path.join(pkgDir, 'bin', target.binName);
  try {
    fs.unlinkSync(rawOut);
  } catch {
    /* ignore */
  }

  const raw = fs.readFileSync(source);
  const compressed = await brotliCompress(raw, {
    params: {
      [zlib.constants.BROTLI_PARAM_QUALITY]: zlib.constants.BROTLI_MAX_QUALITY,
    },
  });
  fs.writeFileSync(outBr, compressed);
  console.log(
    `[assemble] doit-${target.platform}-${target.arch}@${VERSION}: ` +
      `${(raw.length / 1048576).toFixed(1)} MB -> ${(compressed.length / 1048576).toFixed(1)} MB`,
  );
  return true;
}

function stampMetaPackage() {
  const meta = JSON.parse(fs.readFileSync(META_PKG_JSON, 'utf8'));
  meta.version = VERSION;
  const opts = {};
  for (const t of TARGETS) {
    opts[`@dathtd119/doit-${t.platform}-${t.arch}`] = VERSION;
  }
  meta.optionalDependencies = opts;
  fs.writeFileSync(META_PKG_JSON, `${JSON.stringify(meta, null, 2)}\n`);
  console.log(`[assemble] stamped meta @dathtd119/doit@${VERSION}`);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  stampMetaPackage();
  const results = await Promise.all(
    TARGETS.map((t) => packPlatform(t, args.fromArchives)),
  );
  const failed = results.filter((r) => !r).length;
  if (failed > 0) {
    console.error(`[assemble] ${failed} target(s) failed.`);
    process.exit(1);
  }
  console.log(`[assemble] All 6 platform packages ready at ${VERSION}.`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
