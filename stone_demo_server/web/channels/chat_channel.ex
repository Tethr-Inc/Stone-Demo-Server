defmodule StoneDemoServer.ChatChannel do
  use StoneDemoServer.Web, :channel
  alias StoneDemoServer.Presence
  require Logger

  def join("chat:lobby", _payload, socket) do
    Logger.debug "User: #{socket.assigns.user_id} has joined channel: #{socket.topic}"
    send(self, :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:seconds)),
      device_token: socket.assigns.device_token
    })

    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end

  def handle_in("new:msg", %{"body" => body}, socket) do
    Logger.error "-------------"
    broadcast socket, "new:msg", %{
      sender: socket.assigns.user_id,
      body: body
    }
    
    {:reply, :ok, socket}
  end

  def handle_in("new:msg", _, socket), do: {:reply, {:error, %{reason: "unauthorized"}}, socket}
end
