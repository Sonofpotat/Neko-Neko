defmodule MyApp.Database do
  use GenServer

  # Function called when this gen_server child is spawned
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, :ok, name: :handle)
  end

  # Initialization. Called when the module starts.
  def init(:ok) do
    {:ok, [], {:continue, :initial_connection}}
  end

  # Handler to init genserver state
  def handle_continue(_continue_arg, state) do
    {:noreply, state}
  end

  # Receive new data and store it in state
  def handle_info({:new_data, data}, state) do
    {:noreply, state ++ [{data}]}
  end

  # Return genserver state to sender
  def handle_info({:get_state, from}, state) do
    send(from, {:get_state, state})
    {:noreply, state}
  end

  # Unhandled messages
  def handle_info(msg, state) do
    IO.puts("Received an unhandled message: #{inspect(msg)}")
    {:noreply, state}
  end

end
