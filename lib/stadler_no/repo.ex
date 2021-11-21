defmodule StadlerNo.Repo do
  use Ecto.Repo,
    otp_app: :stadler_no,
    adapter: Ecto.Adapters.Postgres
end
