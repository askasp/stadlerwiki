defmodule StadlerNoWeb.PageLive do
  use StadlerNoWeb, :live_view
  import Ecto.Query

  def handle_event("set_tab", %{"tab" => tab}, socket) do
    socket =
      case tab do
        "chart" -> generate_nodes(socket)
        _ -> socket
      end

    {:noreply, assign(socket, tab: tab)}
  end

  def mount(params, %{}, socket) do
    # query = from p in StadlerNo.Wiki.Post,
    post = StadlerNo.Wiki.get_post!(1)
    topic = "everyone"
    StadlerNoWeb.Endpoint.subscribe(topic)

    StadlerNo.Presence.track(
      self(),
      topic,
      socket.id,
      %{}
    )

    count =
      StadlerNo.Presence.list(topic)
      |> Map.keys()
      |> length

    {:ok, assign(socket, post: post, checked: false, tab: "chart", messages: [], reader_count: count, search_result: [])}
  end

  def handle_params(params, uri, socket) do
  	url= URI.parse(uri)
  	host = case url.host do
    	"localhost" -> "http://localhost:4000"
    	x -> "#{url.scheme}://#{url.host}"
    end

  	IO.inspect "host is"
  	IO.inspect host
    post = case params["id"] do
      nil -> StadlerNo.Wiki.get_post!(1)
      x -> StadlerNo.Wiki.get_post!(String.to_integer(x))
    end

  	new_sock = assign(socket, post: post, search_result: [], host: host)
  	|> generate_nodes()

    {:noreply, new_sock}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{reader_count: count}} = socket
      ) do
    reader_count = count + map_size(joins) - map_size(leaves)

    {:noreply, assign(socket, :reader_count, reader_count)}
  end

  def handle_event("toggledrawer", _a, socket) do
    {:noreply, assign(socket, checked: !socket.assigns.checked)}
  end

  def handle_event("search_wiki", %{"search_string" => search_string}, socket) do
    query =
      from(u in StadlerNo.Wiki.Post,
        where: ilike(u.title, ^"%#{String.replace(search_string, "%", "\\%")}%"),
        order_by: [desc: :inserted_at]
      )

    res = StadlerNo.Repo.all(query)
    IO.puts("serach_result is")
    IO.inspect(res)

    {:noreply, assign(socket, search_result: res)}
  end

  def handle_info(%{"message" => _m, "author" => _a} = msg, socket) do
    messages = socket.assigns.messages ++ [msg]
    sock = push_event(socket, "new_message", %{})
    {:noreply, assign(sock, messages: messages)}
  end

  def handle_event("send_message", message, socket) do
    Phoenix.PubSub.broadcast(StadlerNo.PubSub, "everyone", %{"message" => message, "author" => socket.id})
    {:noreply, socket}
  end


  def handle_event("update_page", data, socket) do
    IO.inspect "im here"
    IO.inspect data
    {:noreply, socket}
    # {:noreply, push_patch(socket, to: "/post/#{id}")}
  end



  defp generate_nodes(socket) do
    nodes =
      StadlerNo.Repo.all(StadlerNo.Wiki.Post)
      |> Enum.map(fn node ->
        if node.id == socket.assigns.post.id do
        %{data: %{title: node.title, color: "rgb(252,165,165)", id: "#{node.id}", href: "#{socket.assigns.host}/post/#{node.id}"}}
        else
        %{data: %{title: node.title, color: "white", id: "#{node.id}", href: "#{socket.assigns.host}/post/#{node.id}"}}
        end
      end)

    tags =
      StadlerNo.Repo.all(StadlerNo.Wiki.Tag)
      |> Enum.map(fn tag -> %{data: %{title: tag.name, id: "tag:#{tag.id}", color: "rgb(147,197,253)"}} end)

    links =
      StadlerNo.Repo.all(StadlerNo.Wiki.PostRelationship)
      |> Enum.map(fn edge ->
        %{data: %{id: "#{edge.post_id}:#{edge.relation_id}", source: "#{edge.post_id}", target: "#{edge.relation_id}"}}
      end)

    tag_links =
      StadlerNo.Repo.all(StadlerNo.Wiki.PostTag)
      |> Enum.map(fn edge ->
        %{data: %{id: "#{edge.post_id}:#{edge.tag_id}", source: "tag:#{edge.tag_id}", target: "#{edge.post_id}"}}
      end)

    push_event(socket, "pushEventToJs", %{elements: nodes ++ tags ++ links ++ tag_links})
  end

  def render(assigns) do
    ~H"""
    <div class="drawer drawer-top h-screen overflow-x-hidden ">
    <div class="shadow bg-base-200 drawer drawer-mobile w-screen overflow-x-hidden ">
    <input id="my-drawer-2" type="checkbox" class="drawer-toggle" checked={@checked}>

    <div class="flex flex-col prose drawer-content px-5 py-10 md:mx-20 ">
    <form class="absolute top-5 right-20 w-3/4 md:w-full md:static" phx-change="search_wiki" phx-submit="search_wiki">
    <div class="flex-1 lg:flex-none">
      <div class="form-control">
          <input name="search_string" autocomplete="off" type=
          "text" placeholder="Search wiki" class=
          "mb-0 w-full input h-10 bg-base-100 ">
          <%= if length(@search_result) > 0 do %>
          <ul tabindex="0" class="px-5 relative  shadow-sm menu dropdown-content bg-base-100 rounded-box w-full">
            <%= for  res <- @search_result do %><%= live_patch to: "/post/" <> Integer.to_string(res.id)  do%>
            <div class="p-2"> <%= res.title %> </div>
            <%end %>
            <%end %>
          </ul>
          <% else %>
          <div class="mb-5"> </div>
          <% end %>
        </div>
    </div>
    </form>

    <label for="my-drawer-2" class="mb-12 my-0 drawer-button lg:hidden">
    <button phx-click="toggledrawer" class="absolute top-5 right-5 lg:hidden">
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>               
      </svg>
    </button>

    </label>

    <h1> <%= @post.title %> </h1>
    <div class="mt-5">
    <%= raw(@post.body) %>
    </div>
    </div> 
    <div class="drawer-side min-h-screen"  >
    <label for="my-drawer-2" class="drawer-overlay"></label>
    <div class="overflow-y-auto w-screen md:w-[50vw] bg-base-100 text-base-content px-5  md:px-20 "  >
    <div class="prose mt-10 mb-0 ">

    <h1 class=" mb-0"> Aksel Stadler </h1>
    <div class="mt-0"> Programmer & Robotics Engineer </div>

    <button phx-click="toggledrawer" class="absolute top-5 right-5 lg:hidden">
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current md:w-6 md:h-6">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
    </svg>
    </button>

    <div class="tabs tabs-boxed mt-5 ">
    <button phx-click="set_tab" phx-value-tab="toc" class={is_active_tab(@tab, "toc")}>ToC </button>
    <button phx-click="set_tab" phx-value-tab="chat"class={is_active_tab(@tab, "chat")}>LiveChat</button>
    <button phx-click="set_tab" phx-value-tab="chart" class={is_active_tab(@tab, "chart")} >Chart </button>
    </div>

    <%= case @tab do %>
    <%= "chart" -> %>


<div class="my-5 flex flex-row ...">
    <div class="bg-red-300 w-5 h-5 mx-5"> </div>
    <div> Current node </div>
</div>

<div class="my-2 flex flex-row ...">
    <div class="bg-blue-300 w-5 h-5 mx-5"> </div>
    <div> Tags </div>
</div>


    <div id="cy"  class="w-full md:w-[50vw] md:absolute md:left-0  h-[70vh]"  phx-hook="NodeChart">  </div>
    <%= "chat" ->%> <%= chat(%{messages: @messages, reader_count: @reader_count}) %>
    <%= "toc" ->%> <%= toc(%{}) %>
    <% end %>
    </div>
    </div>
    </div>
    </div>
    <form id="my-form" class="" phx-change="update_page" phx-submit="update_page">
    <input class="hidden" name="id">
    <input id="my-input" class="hidden" name="bubbles">
    </form>
    </div>

    """
  end

  def is_active_tab(tab, actual) do
    if tab == actual do
      "text-lg tab tab-active"
    else
      "text-lg tab "
    end
  end

  def chat(assigns) do
    ~H"""
    <h2 style="margin-top: 1em"> People on page : <%= @reader_count %> </h2>
    <div id="chatPage" phx-hook="SendMsg" class="h-[35vh] md:h-[70vh] py-5 overflow-y-auto">
    <div class="container mx-auto " phx-hook="Scroll" id="messages">
      	<div class="mt-2 mb-4 ">
      		<%= for m <- @messages do %>
    				<div class="p-0 m-0"> <%= m["message"]%> </div>
    				<div class="divider"></div>
    			<% end %>
    	</div>
    </div>
    </div>
    	<div class="form-control mt-5">
    		<form phx-submit="send_message" autocomplete="off">
    			<div class="relative">
    				<input name="message"  id="textarea" type="text" placeholder="message .." class="w-full pr-16 px-5 input input-primary input-bordered">
    				<button type="submit" class="absolute top-0 right-0 rounded-l-none btn btn-primary">Send</button>
    			</div>
    		</form>
    	</div>

    """
  end

  def toc(assigns) do
    ~H"""
    <h2 style="margin-top: 1em"> Table Of Contents: </h2>
    <ul>
    <li class="text-3xl"> About me </li>
    <li class="text-3xl"> Projects </li>
    <li class="text-3xl"> Blogs and random thoughts </li>
    </ul>
    """
  end
end
