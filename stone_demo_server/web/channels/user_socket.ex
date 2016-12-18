defmodule StoneDemoServer.UserSocket do
  use Phoenix.Socket
  require Logger
  ## Channels
  channel "chat:lobby", StoneDemoServer.ChatChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"user_id" => user_id, "device_token" => device_token}, socket) do
    Logger.debug "User: #{user_id} has opened a socket from device: #{device_token}"

    socket = socket
    |> assign(:user_id, user_id)
    |> assign(:device_token, device_token)

    {:ok, socket}
  end

  def connect(_, _socket), do: :error

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     StoneDemoServer.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket) do
    if is_nil(socket.assigns.user_id) do
      nil
    else
      "users_socket:#{socket.assigns.user_id}"
    end
  end
end
