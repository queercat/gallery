defmodule Gallery.Repo.Migrations.AddAuthorToImages do
  use Ecto.Migration

  def change do
    alter table("gallery_images") do
      add :artist, :string, default: ""
      add :source, :string, default: ""
    end
  end
end
