defmodule CenterTest do
	use ExUnit.Case
	doctest Center
end

defmodule TopSupervisorTest do
	use ExUnit.Case
	doctest TopSupervisor

	test "CustomerService" do
		IO.puts("")
		IO.puts(" ** ** CustomerService ** **")
		{:ok, nspid} = NameServer.start()
		{:ok, _tspid} = TopSupervisor.start_link(nspid)

		:timer.sleep(500)
		dbpid = NameServer.resolve(nspid, :CustomerService)
		assert :ok == GenServer.call(dbpid, {:blank})
		Crasher.crash(nspid, :CustomerService)

		:timer.sleep(500)
		dbpid = NameServer.resolve(nspid, :CustomerService)
		assert :ok == GenServer.call(dbpid, {:blank})
		Crasher.crash(nspid, :CustomerService)

		:timer.sleep(500)
		dbpid = NameServer.resolve(nspid, :CustomerService)
		assert :ok == GenServer.call(dbpid, {:blank})
	end

	test "Info" do
		IO.puts("")
		IO.puts(" ** **       Info      ** **")
		{:ok, nspid} = NameServer.start()
		{:ok, _tspid} = TopSupervisor.start_link(nspid)

		:timer.sleep(500)
		ipid = NameServer.resolve(nspid, :Info)
		assert :ok == GenServer.call(ipid, {:blank})
		Crasher.crash(nspid, :Info)

		:timer.sleep(500)
		ipid = NameServer.resolve(nspid, :Info)
		assert :ok == GenServer.call(ipid, {:blank})
		Crasher.crash(nspid, :Info)

		:timer.sleep(500)
		ipid = NameServer.resolve(nspid, :Info)
		assert :ok == GenServer.call(ipid, {:blank})
	end

	test "Shipper" do
		IO.puts("")
		IO.puts(" ** **      Shipper    ** **")
		{:ok, nspid} = NameServer.start()
		{:ok, _tspid} = TopSupervisor.start_link(nspid)

		:timer.sleep(500)
		spid = NameServer.resolve(nspid, :Shipper)
		assert :ok == GenServer.call(spid, {:blank})
		Crasher.crash(nspid, :Shipper)

		:timer.sleep(500)
		spid = NameServer.resolve(nspid, :Shipper)
		assert :ok == GenServer.call(spid, {:blank})
		Crasher.crash(nspid, :Shipper)

		:timer.sleep(500)
		spid = NameServer.resolve(nspid, :Shipper)
		assert :ok == GenServer.call(spid, {:blank})
	end

	test "User" do
		IO.puts("")
		IO.puts(" ** **       User      ** **")
		{:ok, nspid} = NameServer.start()
		{:ok, _tspid} = TopSupervisor.start_link(nspid)

		:timer.sleep(500)
		upid = NameServer.resolve(nspid, :User)
		assert :ok == GenServer.call(upid, {:blank})
		opid = NameServer.resolve(nspid, :Order)
		assert :ok == GenServer.call(opid, {:blank})
		Crasher.crash(nspid, :User)

		:timer.sleep(500)
		upid = NameServer.resolve(nspid, :User)
		assert :ok == GenServer.call(upid, {:blank})
		opid = NameServer.resolve(nspid, :Order)
		assert :ok == GenServer.call(opid, {:blank})
		Crasher.crash(nspid, :User)

		:timer.sleep(500)
		upid = NameServer.resolve(nspid, :User)
		assert :ok == GenServer.call(upid, {:blank})
		opid = NameServer.resolve(nspid, :Order)
		assert :ok == GenServer.call(opid, {:blank})
	end
	test "Order" do 
		IO.puts("")
		IO.puts(" ** **       Order     ** **")
		{:ok, nspid} = NameServer.start()
		{:ok, _tspid} = TopSupervisor.start_link(nspid)

		:timer.sleep(500)
		opid = NameServer.resolve(nspid, :Order)
		assert :ok == GenServer.call(opid, {:blank})
		upid = NameServer.resolve(nspid, :User)
		assert :ok == GenServer.call(upid, {:blank})
		Crasher.crash(nspid, :Order)

		:timer.sleep(500)
		opid = NameServer.resolve(nspid, :Order)
		assert :ok == GenServer.call(opid, {:blank})
		upid = NameServer.resolve(nspid, :User)
		assert :ok == GenServer.call(upid, {:blank})
		Crasher.crash(nspid, :Order)

		:timer.sleep(500)
		opid = NameServer.resolve(nspid, :Order)
		assert :ok == GenServer.call(opid, {:blank})
		upid = NameServer.resolve(nspid, :User)
		assert :ok == GenServer.call(upid, {:blank})
	end

	test "Database" do
		IO.puts("")
		IO.puts(" ** **     Database    ** **")
		{:ok, nspid} = NameServer.start()
		{:ok, _tspid} = TopSupervisor.start_link(nspid)

		:timer.sleep(500)
		dbpid = NameServer.resolve(nspid, :Database)
		assert :ok == GenServer.call(dbpid, {:blank})
		spid = NameServer.resolve(nspid, :Shipper)
		assert :ok == GenServer.call(spid, {:blank})
		ipid = NameServer.resolve(nspid, :Info)
		assert :ok == GenServer.call(ipid, {:blank})
		opid = NameServer.resolve(nspid, :Order)
		assert :ok == GenServer.call(opid, {:blank})
		upid = NameServer.resolve(nspid, :User)
		assert :ok == GenServer.call(upid, {:blank})
		Crasher.crash(nspid, :Database)

		:timer.sleep(500)
		dbpid = NameServer.resolve(nspid, :Database)
		assert :ok == GenServer.call(dbpid, {:blank})
		spid = NameServer.resolve(nspid, :Shipper)
		assert :ok == GenServer.call(spid, {:blank})
		ipid = NameServer.resolve(nspid, :Info)
		assert :ok == GenServer.call(ipid, {:blank})
		opid = NameServer.resolve(nspid, :Order)
		assert :ok == GenServer.call(opid, {:blank})
		upid = NameServer.resolve(nspid, :User)
		assert :ok == GenServer.call(upid, {:blank})
		Crasher.crash(nspid, :Database)

		:timer.sleep(500)
		dbpid = NameServer.resolve(nspid, :Database)
		assert :ok == GenServer.call(dbpid, {:blank})
		spid = NameServer.resolve(nspid, :Shipper)
		assert :ok == GenServer.call(spid, {:blank})
		ipid = NameServer.resolve(nspid, :Info)
		assert :ok == GenServer.call(ipid, {:blank})
		opid = NameServer.resolve(nspid, :Order)
		assert :ok == GenServer.call(opid, {:blank})
		upid = NameServer.resolve(nspid, :User)
		assert :ok == GenServer.call(upid, {:blank})
	end
end

defmodule NameServerTest do
	use ExUnit.Case, async: true
	doctest NameServer

	test "init" do
		assert NameServer.init([]) == {:ok, %{}}
	end

	test "Sync register" do
		assert NameServer.handle_call({:register, :x}, {1,:x}, %{}) == {:reply, :ok, %{:x => 1}}
		assert NameServer.handle_call({:register, :y}, {2,:x}, %{}) == {:reply, :ok, %{:y => 2}}
		map0 = Map.new()
		{:reply, :ok, map1} = NameServer.handle_call({:register, :a}, {1,:x}, map0)
		assert map1 == %{:a => 1}
		{:reply, :ok, map2} = NameServer.handle_call({:register, :b}, {2,:x}, map1)
		assert map2 == %{:a => 1, :b => 2}
		{:reply, :ok, map3} = NameServer.handle_call({:register, :c}, {3,:x}, map2)
		assert map3 == %{:a => 1, :b => 2, :c => 3}
	end

	test "Sync resolve" do
		assert NameServer.handle_call({:resolve, :x}, :caller, %{:x => 1}) == {:reply, 1, %{:x => 1}}
		assert NameServer.handle_call({:resolve, :y}, :caller, %{:x => 1}) == {:reply, :error, %{:x => 1}}
	end

	test "Async register" do
		assert NameServer.handle_cast({:register, :x, 1}, %{}) == {:noreply, %{:x => 1}}
		assert NameServer.handle_cast({:register, :y, 2}, %{}) == {:noreply, %{:y => 2}}
		map0 = Map.new()
		{:noreply, map1} = NameServer.handle_cast({:register, :a, 1}, map0)
		assert map1 == %{:a => 1}
		{:noreply, map2} = NameServer.handle_cast({:register, :b, 2}, map1)
		assert map2 == %{:a => 1, :b => 2}
		{:noreply, map3} = NameServer.handle_cast({:register, :c, 3}, map2)
		assert map3 == %{:a => 1, :b => 2, :c => 3}
	end

	test "Server test" do
		{:ok, spid} = NameServer.start()
		pid = Kernel.self()
		fpid = "#PID<0.9999.0>"
		NameServer.register(spid, "fake testing process", fpid)
		NameServer.register(spid, "testing process")
		assert NameServer.resolve(spid, "testing process") == pid
		assert NameServer.resolve(spid, "fake testing process") == fpid
		assert NameServer.resolve(spid, "bad name") == :error
	end
end
