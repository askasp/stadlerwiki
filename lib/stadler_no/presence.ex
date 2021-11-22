defmodule StadlerNo.Presence do
  use Phoenix.Presence,
    otp_app: :stadler_no,
    pubsub_server: StadlerNo.PubSub
end
