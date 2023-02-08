defmodule Bullet.Socket do
  @moduledoc false

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Bullet.Socket

      use GenServer
      require Logger

      @callback init(map()) ::
                  {:ok, map()}
                  | {:ok, map(), timeout() | :hibernate | {:continue, continue_arg :: term()}}
                  | :ignore
                  | {:stop, reason :: any()}
      @callback handle_continue(term(), map()) ::
                  {:noreply, map(), {:continue, :upgrade}}
                  | {:stop, term(), map()}
                  | {:noreply, map()}
      @callback handle_info(term(), map()) :: {:noreply, map()}

      @connect_opts %{
        connect_timeout: :timer.minutes(1),
        retry: 10,
        retry_timeout: 100
      }
      @spec start_link(map(), atom(), map()) ::
              {:ok, pid()} | :ignore | {:error, {:already_started, pid()} | term()}
      def start_link(connection, name \\ __MODULE__, opts) do
        opts = @connect_opts
        GenServer.start_link(__MODULE__, connection, name: name)
      end

      @impl true
      def init(connection) do
        {:ok, connection, {:continue, :connect}}
      end

      @impl true
      def handle_continue(:connect, connection) do
        {:ok, gun_pid} = :gun.open(connection.host, connection.port, @connect_opts)
        wait_up(connection, gun_pid)
      end

      @impl true
      def handle_continue(:upgrade, connection) do
        :gun.ws_upgrade(connection.gun_pid, connection.path, [])
        {:noreply, connection}
      end

      @impl true
      def handle_info({:gun_down, _pid, :ws, error, _, _}, connection) do
        {:noreply, connection}
      end

      @impl true
      def handle_info({:gun_upgrade, _pid, _stream, _protocols, _headers}, connection) do
        {:noreply, connection}
      end

      @impl true
      def handle_info(
            {:gun_ws, _pid, _ref, _response},
            connection
          ) do
        {:noreply, connection}
      end

      defoverridable init: 1, handle_info: 2, handle_continue: 2

      defp wait_up(connection, gun_pid) do
        case :gun.await_up(gun_pid) do
          {:ok, _} ->
            {:noreply, Map.put(connection, :gun_pid, gun_pid), {:continue, :upgrade}}

          error ->
            {:stop, error, connection}
        end
      end
    end
  end
end
