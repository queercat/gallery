defmodule Gallery.Gallery.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gallery_images" do
    field :data, :string
    field :source, :string
    field :artist, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:data, :artist, :source])
    |> validate_required([:data, :artist, :source])
  end
end
