defmodule Gallery.Repo do
  use Ecto.Repo,
    otp_app: :gallery,
    adapter: Ecto.Adapters.SQLite3
end
