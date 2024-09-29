defmodule Gallery.ImageUpload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "image_upload" do
    field :source, :string
    field :artist, :string
  end

  def changeset(data, attrs) do
    cast(data, attrs, [:source, :artist])
    |> validate_required([:source, :artist])
  end
end
