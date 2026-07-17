#!/usr/bin/env node
// Publish platform packages then meta package to npm.
// Expects assemble-platform-packages.js already ran.
// Auth: NPM_TOKEN env, or npm trusted publishing (OIDC) in GitHub Actions.
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const npmRoot = path.resolve(__dirname, '..', '..');
const metaDir = path.join(npmRoot, 'doit');
const VERSION = JSON.parse(
  fs.readFileSync(path.join(metaDir, 'package.json'), 'utf8'),
).version;

const PLATFORMS = [
  'darwin-arm64',
  'darwin-x64',
  'linux-arm64',
  'linux-x64',
  'win32-arm64',
  'win32-x64',
];

function run(cmd, cwd) {
  console.log(`$ ${cmd}  (cwd=${cwd})`);
  execSync(cmd, { cwd, stdio: 'inherit', env: process.env });
}

function alreadyPublished(name, version) {
  try {
    execSync(`npm view ${name}@${version} version`, {
      stdio: 'pipe',
      env: process.env,
    });
    return true;
  } catch {
    return false;
  }
}

function publishDir(dir, name) {
  if (alreadyPublished(name, VERSION)) {
    console.log(`already published ${name}@${VERSION}`);
    return;
  }
  // Ensure bin payloads exist for platform packages
  if (name !== '@dathtd119/doit') {
    const binDir = path.join(dir, 'bin');
    const entries = fs.existsSync(binDir) ? fs.readdirSync(binDir) : [];
    const hasBr = entries.some((e) => e.endsWith('.br'));
    if (!hasBr) {
      throw new Error(`${name}: no .br binary in ${binDir}`);
    }
  }
  run('npm publish --access public', dir);
}

function main() {
  console.log(`=== npm publish @dathtd119/doit@${VERSION} ===`);
  for (const p of PLATFORMS) {
    const dir = path.join(npmRoot, `doit-${p}`);
    publishDir(dir, `@dathtd119/doit-${p}`);
  }
  publishDir(metaDir, '@dathtd119/doit');
  console.log('=== npm publish done ===');
}

main();
