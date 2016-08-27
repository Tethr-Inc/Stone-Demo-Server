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

  def handle_in("new:msg", %{"body" => body, "images" => images}, socket) when is_map(images) do
    Logger.error "+++++++++++"
    images
    |> Map.values
    |> Enum.each(fn image ->
      {:ok, data} = Base.decode64(image)
      Logger.warn inspect data
    end)

    {:reply, :ok, socket}
  end

  def handle_in("new:msg", %{"body" => _body} = payload, socket) do
    Logger.error "-------------"
    broadcast_payload = Map.merge payload, %{
      user_id: socket.assigns.user_id
    }

    broadcast socket, "new:msg", broadcast_payload
    {:reply, :ok, socket}
  end

  def handle_in("new:msg", _, socket), do: {:reply, {:error, %{reason: "unauthorized"}}, socket}
end
