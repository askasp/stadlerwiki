defmodule StadlerNoWeb.PageLive do
  use StadlerNoWeb, :live_view
  import Ecto.Query

  def render(assigns) do
    ~H"""


<div class="drawer drawer-top h-screen overflow-x-hidden ">

<div class="shadow bg-base-200 drawer drawer-mobile w-screen overflow-x-hidden ">
  <input id="my-drawer-2" type="checkbox" class="drawer-toggle" checked={@checked}>


  <div class="flex flex-col prose drawer-content px-5 py-8 md:mx-20 ">
    <label for="my-drawer-2" class="mb-5 my-0 drawer-button lg:hidden">
<button phx-click="toggledrawer" class="absolute top-5 right-5 lg:hidden">

<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>               
      </svg>
</button>

    </label>

    <h1> <%= @post.title %> </h1>
    <%= raw(@post.body) %>
  </div> 
  <div class="drawer-side min-h-screen"  >
   <label for="my-drawer-2" class="drawer-overlay"></label>
    <div class="overflow-y-auto w-screen md:w-[50vw] bg-base-100 text-base-content px-5  md:px-20 "  >
    <div class="prose mt-10 mb-0 ">
    <h1 class="mt-10 mb-0"> Aksel Stadler </h1>
    <div class="mt-0"> Programmer & Robotics Engineer </div>

    <button phx-click="toggledrawer" class="absolute top-5 right-5 lg:hidden">
			<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current md:w-6 md:h-6">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
  	</svg>
		</button>

	<form class="mt-10">
	<div class="flex-1 lg:flex-none">
    <div class="form-control ">
      <input type="text" placeholder="Search wiki" class="input input-primary bg-gray-100 text-black">
    </div>
  </div>
  </form>


<div class="tabs tabs-boxed mt-5 ">
  <button phx-click="set_tab" phx-value-tab="toc" class={is_active_tab(@tab, "toc")}>ToC </button>
  <button phx-click="set_tab" phx-value-tab="chat"class={is_active_tab(@tab, "chat")}>LiveChat</button>
  <button phx-click="set_tab" phx-value-tab="chart" class={is_active_tab(@tab, "chart")} >Chart </button>
</div>

<%= case @tab do %>
	<%= "chart" -> %> <div id="cy"  class="w-full h-[70vh]"  phx-hook="NodeChart">  </div>
	<%= _ ->%> <%= chat(%{messages: @messages}) %>
	<% end %>

    </div>
    </div>
  </div>
</div>
</div>


    """
  end

  def is_active_tab(tab, actual)  do
    if tab == actual do
      "text-lg tab tab-active"
    else
      "text-lg tab "
  end
  end

  def handle_event("set_tab", %{"tab" => tab}, socket) do
    socket = case tab do
      "chart" -> generate_nodes(socket)
      _ -> socket
      end
    {:noreply, assign(socket, tab: tab)}
  end

  def mount(_params, %{}, socket) do
    # query = from p in StadlerNo.Wiki.Post,
    post = StadlerNo.Wiki.get_post!(1)
    socket = generate_nodes(socket)
    {:ok, assign(socket, post: post, checked: false, tab: "chat", messages: [%{author: "aksel", message: "hei"}, %{author: "tore", message: "samma"}])}
  end

  def handle_event("toggledrawer", _a, socket) do
    {:noreply, assign(socket, checked: !socket.assigns.checked)}

  end

  defp generate_nodes(socket) do
    nodes = StadlerNo.Repo.all(StadlerNo.Wiki.Post)
    |> Enum.map(fn node -> %{data: %{title: node.title, color: "white", id: "#{node.id}", href: "localhost:4000/hei"}} end)

    tags = StadlerNo.Repo.all(StadlerNo.Wiki.Tag)
    |> Enum.map(fn tag -> %{data: %{title: tag.name, id: "tag:#{tag.id}", color: "#31a5f4" }} end)


    links = StadlerNo.Repo.all(StadlerNo.Wiki.PostRelationship)
    |> Enum.map(fn edge -> %{data: %{id: "#{edge.post_id}:#{edge.relation_id}", source: "#{edge.post_id}", target: "#{edge.relation_id}"}} end)

    tag_links= StadlerNo.Repo.all(StadlerNo.Wiki.PostTag)
    |> Enum.map(fn edge -> %{data: %{id: "#{edge.post_id}:#{edge.tag_id}",  source: "tag:#{edge.tag_id}", target: "#{edge.post_id}"}} end)

    push_event(socket, "pushEventToJs", %{elements: nodes ++  tags ++ links ++ tag_links})
  end

  def chat(assigns) do
    ~H"""
    <div class="h-screen">
  		<div id="chatPage" phx-hook="SendMsg"> </div>
			<div class="container mx-auto " phx-hook="Scroll" id="messages">
      	<div class="mt-8 mb-16 ">
      		<%= for m <- @messages do %>
    				<b class=""> <%= m.author %> </b>
    				<div class="p-0 m-0"> <%= m.message %> </div>
    				<div class="divider"></div>
   				<% end %>
  			</div>

    	<div class="form-control mt-5 ">
    		<form phx-submit="send_message" autocomplete="off">
    			<div class="relative">
    				<input name="message"  id="textarea" type="text" placeholder="message .." class="w-full pr-16 px-5 input input-primary input-bordered">
    				<button type="submit" class="absolute top-0 right-0 rounded-l-none btn btn-primary">Send</button>
    			</div>
    		</form>
    	</div>
    </div>
    </div>



    """
  end






end
