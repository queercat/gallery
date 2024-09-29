defmodule GalleryWeb.Components.ImageUpload do
  alias Gallery.Gallery.Image
  alias Gallery.Repo
  use GalleryWeb, :live_component
  alias Gallery.ImageUpload

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-change="validate" phx-submit="save" phx-target={@myself}>
        <div
          class="flex gap-2 flex-col p-2 border-dashed border-white-500 hover:border-sky-500 transition-[border] border-2 w-fit"
          id="dropzone"
          phx-hook="DragDrop"
          phx-drop-target={@uploads.image.ref}
        >
          <.input type="text" name="artist" field={@form[:artist]} label="Artist" />
          <.input type="text" name="source" field={@form[:source]} label="Source" />
          <.live_file_input upload={@uploads.image} />
          <button
            type="submit"
            class="text-white bg-green-500 px-2 py-1 rounded-sm w-fit"
            phx-disable-with="Uploading..."
            disabled={
              String.length(@form[:artist].value) <= 0 or String.length(@form[:source].value) <= 0
            }
          >
            Upload
          </button>
          <%= if String.length(@error) > 0 do %>
            <div class="border-2 p-2 border-rose-600 bg-rose-400 rounded-sm flex">
              <p class="text-black"><%= @error %></p>
            </div>
          <% end %>
        </div>
      </.form>
    </div>
    """
  end

  def handle_event("validate", params, socket) do
    form =
      ImageUpload.changeset(%ImageUpload{}, params) |> Map.put(:action, :validate) |> to_form()

    socket = socket |> assign(form: form)

    {:noreply, socket}
  end

  def handle_event("save", _params, socket)
      when length(socket.assigns.uploads.image.entries) == 0 do
    socket = socket |> assign(error: "Missing image!")
    {:noreply, socket}
  end

  def handle_event("save", %{"artist" => artist, "source" => source}, socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
      data =
        File.read!(path)
        |> Base.encode64()
        |> mimeify()

      image = %Image{artist: artist, source: source, data: data}

      Repo.insert(image)

      Phoenix.PubSub.broadcast(Gallery.PubSub, "gallery", {:update, image})

      {:ok, path}
    end)

    {:noreply, socket}
  end

  def mimeify(base64) do
    start = String.at(base64, 0) |> IO.inspect()

    addition =
      %{
        "/" => "jpeg",
        "i" => "png",
        "R" => "gif",
        "U" => "webp"
      }[start]

    "data:image/" <> addition <> ";base64," <> base64
  end
end
