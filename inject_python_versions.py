#!/usr/bin/python

import os
import re


re_version = re.compile('^python(\d+)\.(\d+)$')

versions = []
for filename in os.listdir('/usr/bin'):
    match = re_version.match(filename)
    if match:
        versions.append({'filename': filename, 'version': (match.groups())})

if not versions:
    print('No python versions found in /usr/bin')

    exit(1)

versions.sort(key=lambda version: version['version'])

# Inject into setup.py.
with open('setup.py', 'r') as f:
    setup_lines = f.readlines()

for line, setup_line in enumerate(setup_lines):
    if setup_line.endswith('Programming Language :: Python\',\n'):
        indent = setup_line[:setup_line.find('\'')]
        break
else:  # nobreak
    print('Malformed setup.py.')

    exit(2)

line += 1

setup_versions = []
majors_seen = []
template = '{indent}\'Programming Language :: Python :: {major}\',\n'
template_with_minor = (
    '{indent}\'Programming Language :: Python :: {major}.{minor}\',\n'
)

for version in versions:
    major, minor = version['version']
    if major not in majors_seen:
        setup_versions.append(template.format(indent=indent, major=major))
        majors_seen.append(major)

    setup_versions.append(
        template_with_minor.format(indent=indent, major=major, minor=minor)
    )

setup_string = ''.join(
    setup_lines[:line] + setup_versions + setup_lines[line:]
)

# Inject into tox.ini.
with open('tox.ini', 'r') as f:
    tox_lines = f.readlines()

for line, tox_line in enumerate(tox_lines):
    if tox_line.startswith('envlist'):
        break
else:  # nobreak
    print('Malformed tox.ini.')

    exit(3)

envlist = ','.join([
    'py{version}'.format(version=''.join(version['version']))
    for version in versions
])

tox_string = ''.join(
    tox_lines[:line] +
    ['envlist = {envlist}\n'.format(envlist=envlist)] +
    tox_lines[line + 1:]
)

# Write changes.
with open('setup.py', 'w') as f:
    f.write(setup_string)

with open('tox.ini', 'w') as f:
    f.write(tox_string)
