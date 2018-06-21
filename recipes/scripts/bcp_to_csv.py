import sys
import csv

f = sys.stdin.buffer
writer = csv.writer(sys.stdout, lineterminator='\n')

def lines(f):
    line = b''
    while True:
        c = f.read(1)
        if c == b'':
            break
        elif c == b'\x00':
            continue
        elif c== b'\x1e':
            yield line.decode()
            line = b''
        else:
            line += c
    

for line in lines(f):
    line = line.replace('\r', '')
    line = line.replace('\\r', '')
    line = line.replace('\\n', '\n')
    row = line.split('\x1d')
    writer.writerow(row)


sys.stdout.flush()
