import { execFileSync } from 'node:child_process';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname } from 'node:path';

const [zbaseImage, output] = process.argv.slice(2);

if (!zbaseImage || !output) {
  throw new Error('usage: node hack/generate-packages.mjs <zbase-image> <output>');
}

const dockerfile = readFileSync('zbase/Dockerfile', 'utf8');
const baseImage = dockerfile.match(/^FROM\s+(\S+)/m)?.[1];

if (!baseImage) {
  throw new Error('failed to find the base image in zbase/Dockerfile');
}

const extensionDirectory = '/var/www/html/extensions';
const inventoryCommand = `
  for directory in ${extensionDirectory}/*; do
    test -d "$directory" || continue
    extension="${'${directory##*/}'}"
    metadata=''
    if test -f "$directory/extension.json"; then
      metadata="$(base64 -w 0 "$directory/extension.json")"
    fi
    printf '%s\\0%s\\0' "$extension" "$metadata"
  done
`;

function extensionsIn(image) {
  const output = execFileSync(
    'docker',
    ['run', '--rm', image, 'sh', '-c', inventoryCommand],
    { encoding: 'buffer' },
  );
  const records = output.toString('utf8').split('\0');
  const extensions = new Map();

  for (let index = 0; index < records.length - 1; index += 2) {
    const [name, encodedMetadata] = records.slice(index, index + 2);
    if (!name) continue;

    let version = '-';
    if (encodedMetadata) {
      const metadata = JSON.parse(Buffer.from(encodedMetadata, 'base64').toString('utf8'));
      version = metadata.version ?? '-';
    }
    extensions.set(name, String(version));
  }

  return extensions;
}

const bundledExtensions = extensionsIn(baseImage);
const zbaseExtensions = extensionsIn(zbaseImage);
const zbaseTag = zbaseImage.split('/').at(-1);

const packages = [...zbaseExtensions]
  .map(([extension, version]) => ({
    source: bundledExtensions.has(extension) ? 'bundled' : 'zbase',
    extension,
    version,
    image: bundledExtensions.has(extension) ? baseImage : zbaseTag,
  }))
  .sort((left, right) =>
    left.source.localeCompare(right.source) || left.extension.localeCompare(right.extension),
  );

const columns = [
  ['SOURCE', 'source'],
  ['EXTENSION', 'extension'],
  ['VERSION', 'version'],
  ['IMAGE', 'image'],
];
const widths = Object.fromEntries(
  columns.map(([heading, key]) => [
    key,
    Math.max(heading.length, ...packages.map((packageInfo) => packageInfo[key].length)),
  ]),
);
const format = (packageInfo) =>
  columns.map(([, key]) => packageInfo[key].padEnd(widths[key])).join('  ').trimEnd();

mkdirSync(dirname(output), { recursive: true });
writeFileSync(
  output,
  [
    `# Generated from ${zbaseImage} (base: ${baseImage}).`,
    format(Object.fromEntries(columns.map(([heading, key]) => [key, heading]))),
    ...packages.map(format),
    '',
  ].join('\n'),
);
