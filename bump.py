with open('netrange.sh', 'rb') as f:
    c = f.read().replace(b'\r\n', b'\n')
c = c.replace(b'VERSION="2.0.0"', b'VERSION="2.1.0"')
c = c.replace(b'NetRange v2.0', b'NetRange v2.1')
with open('netrange.sh', 'wb') as f:
    f.write(c)

with open('README.md', 'rb') as f:
    r = f.read().replace(b'version-2.0.0', b'version-2.1.0').replace(b'NetRange v2.0', b'NetRange v2.1')
with open('README.md', 'wb') as f:
    f.write(r)

with open('install.sh', 'rb') as f:
    i = f.read().replace(b'NetRange v2.0', b'NetRange v2.1').replace(b'\r\n', b'\n')
with open('install.sh', 'wb') as f:
    f.write(i)

with open('CHANGELOG.md', 'rb') as f:
    ch = f.read().replace(b'v2.0.0', b'v2.1.0')
with open('CHANGELOG.md', 'wb') as f:
    f.write(ch)
