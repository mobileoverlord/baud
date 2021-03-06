defmodule Baud.LoopRawTest do
  use ExUnit.Case
  alias Baud.TestHelper

  test "raw echo" do
    exec = :code.priv_dir(:baud) ++ '/native/baud'
    tty0 = TestHelper.tty0()
    args0 = ["o#{tty0},115200,8N1b8i100fde0lr", Atom.to_string(__MODULE__)]
    port0 = Port.open({:spawn_executable, exec}, [:binary, packet: 2, args: args0])
    tty1 = TestHelper.tty1()
    {:ok, pid1} = Baud.start_link([portname: tty1, name: Atom.to_string(__MODULE__)])
    assert_receive {^port0, {:data, "0"}}, 400
    :ok = Baud.discard(pid1)

    true = Port.command(port0, "echo0")
    {:ok, "echo0"} = Baud.read(pid1, 5, 400)
    :ok = Baud.write(pid1, "echo1")
    assert_receive {^port0, {:data, "echo1"}}, 400

    true = Port.close(port0)
    :ok = Baud.close(pid1)
  end

end
