defmodule GalleryWeb.IndexLive do
  alias Gallery.Repo
  alias Gallery.ImageUpload

  use GalleryWeb, :live_view

  import Ecto.Query

  def mount(_params, _session, socket) do
    query = from i in Gallery.Gallery.Image, select: i, order_by: [desc: i.inserted_at]

    Phoenix.PubSub.subscribe(Gallery.PubSub, "gallery")

    images =
      Repo.all(query)

    form = to_form(ImageUpload.changeset(%ImageUpload{artist: "", source: ""}, %{}))

    socket =
      socket
      |> assign(images: images)
      |> assign(uploaded_files: [])
      |> assign(form: form)
      |> assign(error: "")
      |> allow_upload(:image, accept: ~w(.png .jpg .jpeg .gif .webp))

    socket |> IO.inspect()

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex p-2 flex-col gap-4 items-center w-full">
      <.live_component
        module={GalleryWeb.Components.ImageUpload}
        uploads={@uploads}
        form={@form}
        error={@error}
        id="image_upload"
      />
      <.gallery images={@images} />
    </div>
    """
  end

  attr :key, :string, required: true
  attr :value, :string, required: true
  attr :link, :string, default: "#"
  attr :rest, :string, default: ""

  def badge_item(assigns) do
    ~H"""
    <div class="w-full bg-black p-2 rounded-sm hover:shadow-lg transition-shadow flex justify-center items-center gap-2">
      <p class="ubuntu-bold"><%= @key %>:</p>
      <a href={@link} class={@rest <> " bg-blue-500 py-1 px-2 rounded-sm text-black truncate"}>
        <%= @value %>
      </a>
    </div>
    """
  end

  attr :images, :any, required: true

  def gallery(assigns) do
    ~H"""
    <div class="justify-center flex ubuntu-regular gap-4 flex-wrap w-full">
      <div
        :for={i <- @images}
        class="p-2 bg-gray-400 rounded-sm size-fit shadow-sm hover:shadow-xl transition-shadow gallery-image"
      >
        <div class="grid gap-1">
          <img src={i.data} width={300} class="rounded-sm" />
          <.badge_item link={i.source} rest="bg-orange-500" key="Artist" value={i.artist} />
          <.badge_item link={i.source} key="Source" value={URI.parse(i.source).host || i.source} />
        </div>
      </div>
    </div>
    """
  end

  def handle_info({:update, image}, socket) do
    {:noreply, Phoenix.Component.update(socket, :images, fn images -> [image | images] end)}
  end
end
