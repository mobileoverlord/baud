
{:ok, pid} = Baud.start_link([portname: "cu.usbserial-FTVFV143", baudrate: 57600])
#force 0 to coil at slave 1 address 3000
:ok = Baud.rtu(pid, {:fc, 1, 3000, 0}, 400)
#read 0 from coil at slave 1 address 3000
{:ok, [0]} = Baud.rtu(pid, {:rc, 1, 3000, 1}, 400)
#force 10 to coils at slave 1 address 3000 to 3001
:ok = Baud.rtu(pid, {:fc, 1, 3000, [1, 0]}, 400)
#read 10 from coils at slave 1 address 3000 to 3001
{:ok, [1, 0]} = Baud.rtu(pid, {:rc, 1, 3000, 2}, 400)
#preset 55AA to holding register at slave 1 address 3300
:ok = Baud.rtu(pid, {:phr, 1, 3300, 0x55AA}, 400)
#read 55AA from holding register at slave 1 address 3300 to 3301
{:ok, [0x55AA]} = Baud.rtu(pid, {:rhr, 1, 3300, 1}, 400)
