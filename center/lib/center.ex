defmodule Center do
	@moduledoc """
	Documentation for Center.
	"""

	@doc """
	Hello world.

	## Examples

			iex> Center.hello
			:world

	"""
	def hello do
		:world
	end
end

defmodule TopSupervisor do
	use Supervisor

	def start_link(nameServer) do
		Supervisor.start_link(__MODULE__, nameServer)
	end

	def init(nameServer) do
	children = [
		worker(DatabaseSupervisor, [nameServer]),
		worker(CustomerService, [nameServer])
	]
	supervise(children, strategy: :one_for_one)
	end
end

defmodule DatabaseSupervisor do
	use Supervisor

	def start_link(nameServer) do
	Supervisor.start_link(__MODULE__, nameServer)
	end

	def init(nameServer) do
	children = [
		worker(Database, [nameServer]),
		worker(DatabaseDepSupervisor, [nameServer])
	]
	supervise(children, strategy: :rest_for_one)
	end
end

defmodule DatabaseDepSupervisor do
	use Supervisor

	def start_link(nameServer) do
	Supervisor.start_link(__MODULE__, nameServer)
	end

	def init(nameServer) do
	children = [
		worker(Info, [nameServer]),
		worker(Shipper, [nameServer]),
		worker(InterSupervisor, [nameServer])
	]
	supervise(children, strategy: :one_for_one)
	end
end

defmodule InterSupervisor do
	use Supervisor

	def start_link(nameServer) do
	Supervisor.start_link(__MODULE__, nameServer)
	end

	def init(nameServer) do
	children = [
		worker(User, [nameServer]),
		worker(Order, [nameServer])
	]
	supervise(children, strategy: :one_for_all)
	end
end


defmodule NameServer do
	use GenServer

	def init(_) do
		{:ok, Map.new()}
	end

	def start_link() do
		GenServer.start_link(__MODULE__, [], [])
	end

	def start_link(default) do
		GenServer.start_link(__MODULE__, default)
	end

	def start() do
		GenServer.start(__MODULE__, Map.new(), [])
	end


	def handle_call({:register, name}, {pid, _from}, registry) do
		newRegistry = Map.put(registry, name, pid)
		{:reply, :ok, newRegistry}
	end

	def handle_call({:resolve, name}, _sender, registry) do
		case Map.fetch(registry, name) do
			:error ->
				{:reply, :error, registry}
			{:ok, pid} ->
				{:reply, pid, registry}
		end
	end

	def handle_call(request, from, state) do
		super(request, from, state)
	end


	def handle_cast({:register, name, pid}, registry) do
		newRegistry = Map.put(registry, name, pid)
		{:noreply, newRegistry}
	end

	def handle_cast(request, state) do
		super(request, state)
	end


	def hande_info(_msg, state) do
		{:noreply, state}
	end


	# begin "for testing"
	def register(name_server, name) do
		GenServer.call(name_server, {:register, name})
	end

	def register(name_server, name, pid) do
		GenServer.cast(name_server, {:register, name, pid})
	end

	def resolve(name_server, name) do
		GenServer.call(name_server, {:resolve, name})
	end
	# end "for testing"
end
