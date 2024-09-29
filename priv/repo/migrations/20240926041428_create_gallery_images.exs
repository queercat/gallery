defmodule Gallery.Repo.Migrations.CreateGalleryImages do
  use Ecto.Migration

  def change do
    create table(:gallery_images) do
      add :data, :string

      timestamps(type: :utc_datetime)
    end
  end
end
