import { readFileSync, writeFileSync } from 'node:fs';

const [upstreamFile, localFile, dockerfile] = process.argv.slice(2);

if (!upstreamFile || !localFile || !dockerfile) {
  throw new Error('usage: node hack/preflight-extensions.mjs <upstream.yaml> <extensions.yaml> <Dockerfile>');
}

function yamlValue(value) {
  const trimmed = value.trim();
  if ((trimmed.startsWith('"') && trimmed.endsWith('"')) || (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
    return trimmed.slice(1, -1);
  }
  return trimmed;
}

function parseExtensions(filename) {
  const extensions = [];
  let extension;

  for (const line of readFileSync(filename, 'utf8').split(/\r?\n/)) {
    const entry = line.match(/^\s*-\s+name:\s*(.+?)\s*$/);
    if (entry) {
      if (extension) extensions.push(extension);
      extension = { name: yamlValue(entry[1]) };
      continue;
    }

    const property = line.match(/^\s+(repo|tag):\s*(.+?)\s*$/);
    if (property && extension) extension[property[1]] = yamlValue(property[2]);
  }
  if (extension) extensions.push(extension);

  for (const entry of extensions) {
    if (!entry.name || !entry.repo || !entry.tag) {
      throw new Error(`${filename}: each extension must define name, repo, and tag`);
    }
  }
  return extensions;
}

function versionParts(tag) {
  const match = tag.match(/^v?(\d+(?:\.\d+)*)$/);
  if (!match) throw new Error(`unsupported extension tag: ${tag}`);
  return match[1].split('.').map(Number);
}

function compareVersions(left, right) {
  const leftParts = versionParts(left);
  const rightParts = versionParts(right);
  const length = Math.max(leftParts.length, rightParts.length);
  for (let index = 0; index < length; index += 1) {
    const difference = (leftParts[index] ?? 0) - (rightParts[index] ?? 0);
    if (difference !== 0) return difference;
  }
  return 0;
}

const upstream = parseExtensions(upstreamFile);
const local = parseExtensions(localFile);
const localByName = new Map(local.map((extension) => [extension.name, extension]));

for (const required of upstream) {
  const configured = localByName.get(required.name);
  if (!configured) {
    throw new Error(`${localFile}: missing extension required by zengine: ${required.name}`);
  }
  if (compareVersions(configured.tag, required.tag) < 0) {
    throw new Error(
      `${localFile}: ${required.name} is ${configured.tag}; zengine requires at least ${required.tag}`,
    );
  }
}

const tagWidth = Math.max(...local.map((extension) => extension.tag.length));
const repoWidth = Math.max(...local.map((extension) => extension.repo.length));
const generated = local
  .map(
    ({ name, repo, tag }) =>
      `    && git clone --depth=1 -b ${tag.padEnd(tagWidth)} ${repo.padEnd(repoWidth)} ${name} \\`,
  )
  .join('\n');
const startMarker = '    # auto-generated';
const endMarker = '    # /auto-generated';
const contents = readFileSync(dockerfile, 'utf8');
const start = contents.indexOf(startMarker);
const end = contents.indexOf(endMarker);

if (start === -1 || end === -1 || end < start) {
  throw new Error(`${dockerfile}: missing or invalid auto-generated markers`);
}

const before = contents.slice(0, start + startMarker.length);
const after = contents.slice(end);
writeFileSync(dockerfile, `${before}\n${generated}\n${after}`);
