# baud

Serial port with Modbus support.

Basic Modbus support:

- **Interactice RTU**: RTU commands are send interactively.

Low level advanced Modbus support:

- **RTU TCP Gateway Loop**: Modbus TCP requests received by the native port are translated to RTU and forwarded to serial port. Responses are translated back from RTU to TCP.
- **RTU Master Loop**: Modbus RTU requests received by the native port are padded with CRC and forwarded to serial port. Responses are checked and unpadded back.
- **RTU Slave Loop**: Modbus RTU requests received by the native port port are checked and unpadded from CRC and forwarded to socket. Responses are padded and forwarded back.

Some of these modes of operation feature samples below. See the unit tests for more usage samples.

## Installation and Usage

  1. Add `baud` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:baud, "~> 0.4.0"}]
    end
    ```

  2. Build & test it:

  See [NOTES](NOTES.md) for platform specific instructions on setting up your development environment.

  ```shell
  #Serial port names are hard coded in test_helper.exs
  #A couple of null modem serial ports are required
  #com0com may work on Windows but not tested yet
  ./test.sh
  ```

  3. Use it to enumerate serial ports

    ```elixir
    alias Baud.Enum
    ["COM1", "ttyUSB0", "cu.usbserial-FTVFV143"] = Enum.list()
    ```

  4. Use it to interact with your serial port

    ```elixir
    #Do not prepend /dev/ to the port name
    #Try this with a loopback
    {:ok, pid} = Baud.start_link([portname: "cu.usbserial-FTYHQD9MA"])
    #Send data
    :ok = Baud.write(pid, "Hello");
    #Wait data is transmitted
    :ok = Baud.wait4tx(pid, 400)
    #Wait at least 5 bytes are available
    :ok = Baud.wait4rx(pid, 5, 400)
    #Check at least 5 bytes are available
    {:ok, 5} = Baud.available(pid);
    #Read 4 bytes of data
    {:ok, "Hell"} = Baud.read(pid, 4, 400);
    #Read all available data
    {:ok, "o"} = Baud.read(pid);
    #Send more data
    :ok = Baud.write(pid, "World!\n...");
    #Wait at least 1 byte is available
    :ok = Baud.wait4rx(pid, 1, 400)
    #Read all data up to first newline
    {:ok, "World!\n"} = Baud.readln(pid, 400);
    #Discard the trailing ...
    :ok = Baud.discard(pid)
    #Check nothing is available
    {:ok, 0} = Baud.available(pid);
    #Check the native port is responding
    :ok = Baud.echo(pid)
    #Close the native serial port
    :ok = Baud.close(pid)
    #Stop the server
    :ok = Baud.stop(pid)
    ```

  5. Use it to interact with your **RTU** devices.

    ```elixir    
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
    ```

  6. Use it to export your serial port to a socket in **raw** mode with no buffering so that the socket (being faster) receives bytes from the serial port (being slower) as they arrive unless a packetization timeout is configured.

    ```elixir
    alias Baud.Sock
    #Do not prepend /dev/ to the port name. Mode defaults to :raw
    {:ok, pid} = Sock.start_link([portname: "ttyUSB0", port: 5000])
    #use netcat to talk to the serial port
    #nc 127.0.0.1 5000
    :ok = Sock.stop(pid)    
    ```

  7. Use it to export your serial port to a socket in **text** mode with input buffering up the a newline at the serial port level to avoid to many context switches between Erlang and the native port due to the differences of socket and serial port speed.

    ```elixir
    alias Baud.Sock
    #Do not prepend /dev/ to the port name.
    {:ok, pid} = Sock.start_link([portname: "ttyUSB0", port: 5000, mode: :text])
    #use netcat to talk to the serial port
    #nc 127.0.0.1 5000
    :ok = Sock.stop(pid)    
    ```

  8. Use it to export your serial port to a socket in **tcp gateway** mode where TCP received in socket is translated back and forth to RTU on serial port.

    ```elixir
    alias Baud.Sock
    #Do not prepend /dev/ to the port name.
    {:ok, pid} = Sock.start_link([portname: "ttyUSB0", port: 5000, mode: :rtu_tcpgw])
    #modbus TCP commands sent to 127.0.0.1:5000 will be forwarded as RTU to serial port
    :ok = Sock.stop(pid)    
    ```

## Releases

Version 0.4.0

- [x] Added sample scripts (1 y 2)
- [x] Improved documentation
- [x] Update to modbus 0.2.0 (refactoring required)

Version 0.3.0

- [x] Integration test script for modport
- [x] Added test.sh to isolate tests run
- [x] RTU master, slave, and tcpgw loop modes
- [x] Serial port export to socket in raw, text, and modbus mode
- [x] RTU API matched to `modbus` package (1,2,3,4,5,6,15,16)
- [x] Improved timeout handling for shorter test times

Version 0.2.0

- [x] Interactive RTU: read/write up to 8 coils at once

Version 0.1.0

- [x] Cross platform native serial port (mac, win, linux)
- [x] Modbus (tcu-rtu), raw and text loop mode

## TODO

- [ ] loop* tests still show data corruption when run all at once
- [ ] Implement Modbus ASCII support (no available device)
- [ ] Implement DTR/RTS control and CTS/DSR monitoring
- [ ] Implement separate discard for input and output buffers
- [ ] Unit test 8N1 7E1 7O1 and baud rate setup against a confirmed gauge
- [ ] Get port names required for unit testing from environment variables
- [ ] Implement a clean exit to loop mode for a timely port close and to ensure test isolation
- [ ] Improve debugging: stderr messages are interlaced in mix test output
- [ ] Improve debugging: dev/test/prod conditional output
- [ ] Move from polling to overlapped on Windows
- [ ] Research why interchar timeout is applied when reading a single byte even having many already in the input buffer. Happens on MAC.
- [ ] Research how to bypass the 0.1s minimum granularity on posix systems
- [ ] Research Mix unit test isolation (OS resources cleanup)
- [ ] Research printf to embed variable sized arrays as hex strings
