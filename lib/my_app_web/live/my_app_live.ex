defmodule MyAppWeb.MyAppLive do
  use MyAppWeb, :live_view


  # Define the socket's initial state
  def mount(_params, _session, socket) do
    kotos = [
      %{name: "Cica", aggression: 7, strength: 5, enchantment: 8},
      %{name: "Ragu", aggression: 6, strength: 6, enchantment: 7},
      %{name: "Punya", aggression: 8, strength: 7, enchantment: 6},
      %{name: "Harais", aggression: 5, strength: 8, enchantment: 7},
      %{name: "Mawaru", aggression: 6, strength: 7, enchantment: 5},
      %{name: "Mintu", aggression: 5, strength: 8, enchantment: 7},
      %{name: "Yuiuya", aggression: 7, strength: 6, enchantment: 7},
      %{name: "Chapa", aggression: 8, strength: 6, enchantment: 5}
    ]

    # Generate image paths for each koto
    kotos_with_paths = Enum.map(kotos, fn koto ->
      Map.put(koto, :image_path, image_path(koto))
    end)

    # Initial state of the socket with default values
    {:ok, assign(socket, kotos: kotos_with_paths,
                          selected_kotos: [],
                          selected_attribute: nil,
                          result: "")}
  end

  # Helper function to create the image path
  defp image_path(koto) do
    "/cards/#{String.downcase(koto.name)}.png"
  end

  # Define how to handle events from the client
  def handle_event("compare", _params, socket) do
    selected_kotos = socket.assigns.selected_kotos

    # Ensure we have exactly two kotos to compare
    if length(selected_kotos) != 2 do
      {:noreply, assign(socket, result: "Select exactly 2 kotos to compare")}
    else
      [koto1, koto2] = selected_kotos
      result = compare_sum_of_attributes(koto1, koto2)
      {:noreply, assign(socket, result: result)}
    end
  end

  def handle_event("select_koto", %{"name" => koto_name}, socket) do
    kotos = socket.assigns.kotos
    selected_koto = Enum.find(kotos, &(&1.name == koto_name))

    # Safely update :selected_kotos since it has been initialized
    selected_kotos = [selected_koto | socket.assigns.selected_kotos] |> Enum.uniq() |> Enum.take(2)

    {:noreply, assign(socket, selected_kotos: selected_kotos)}
  end

  defp compare_sum_of_attributes(koto1, koto2) do
    # Calculate the sum of attributes for each koto
    sum1 = sum_of_attributes(koto1)
    sum2 = sum_of_attributes(koto2)

    # Compare the sums and return a message
    cond do
      sum1 > sum2 -> "#{koto1.name} WINS with a total of #{sum1} points over #{koto2.name} with #{sum2} points"
      sum1 < sum2 -> "#{koto2.name} WINS with a total of #{sum2} points over #{koto1.name} with #{sum1} points"
      true        -> "Both #{koto1.name} and #{koto2.name} have the same total points of #{sum1}"
    end
  end

  # Helper function to calculate the sum of attributes
  defp sum_of_attributes(koto) do
    koto.aggression + koto.strength + koto.enchantment
  end

  defp compare_kotos(koto1, koto2, attribute) do
    # Use pattern matching to extract the attribute values and names
    %{^attribute => value1, name: name1} = koto1
    %{^attribute => value2, name: name2} = koto2

    # Compare the attribute values and return a message
    cond do
      value1 > value2 -> "#{name1} wins in #{attribute} over #{name2}"
      value1 < value2 -> "#{name2} wins in #{attribute} over #{name1}"
      true           -> "Both #{name1} and #{name2} have the same #{attribute} value"
    end
  end


  def render(assigns) do
    ~H"""
      <div id="koto-cards">
        <%= for koto <- assigns.kotos do %>
        <div class="card" phx-click="select_koto" phx-value-name={koto.name}>
        <!-- Call `card_image_path/1` with `koto` to generate the path -->
        <img src={koto.image_path} />
        <p><%= koto.name %></p>
        <ul class="card-attributes">
        <li>Aggression: <%= koto.aggression %></li>
        <li>Strength: <%= koto.strength %></li>
        <li>Enchantment: <%= koto.enchantment %></li>
      </ul>
      </div>
        <% end %>
      </div>
      <div id="selected_kotos">
          <h2>Selected Kotos</h2>
          <ul>
            <%= for koto <- @selected_kotos do %>
            <li>
            <span class="koto-name"><%= koto.name %></span>
            <img src={koto.image_path} class="small-image" />
          </li>
            <% end %>
          </ul>
        </div>
        <div id="compare-buttons">
          <button phx-click="compare">Compare!</button>
        </div>
      <div id="result">
        <p><%= assigns.result %></p>
      </div>
      """
  end
end
