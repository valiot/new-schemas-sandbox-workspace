defmodule Debug do
  @moduledoc """
  Debugging functions for making life easier.
  """

  @bw not Application.get_env(:wspace_ui, :workspace)
  @width 80
  @color 255
  @line_color 238
  @time_color 238
  @syntax_colors [
    atom: :cyan,
    binary: :white,
    boolean: :magenta,
    list: :white,
    map: :white,
    nil: :magenta,
    number: :yellow,
    regex: :light_red,
    reset: :yellow,
    string: :green,
    tuple: :white
  ]
  @line_char (if not @bw do "─" else "-" end)

  @doc """
  Prints `input` in console within a formatted frame.

  Returs `input`.

  It can recieve a keyword list as options.

  ## Options
    * `label`: A string to print on the header for identification purposes.
    * `color`: Color of the label if its given. Values between 0-255.
    * `width`: Number of char width of the output.
    * `line_color`: Color of the header and footer lines. Values between 0-255.
    * `time_color`: Color of the execution time. Values between 0-255.
    * `app_color`: Color of the schema app name. Values between 0-255.
    * `syntax_colors`: Keyword list for term syntax color.
      
      Keys: `:atom`, `:binary`, `:boolean`, `:list`, `:map`, `:nil`, `:number`, `:regex`, `:reset`, `:string`, `:tuple`.
      
      Values: `:black`, `:red`, `:yellow`, `:green`, `:cyan`, `:blue`, `:magenta`, `:white`, `:light_black`, `:light_red`, `:light_yellow`, `:light_green`, `:light_cyan`, `:light_blue`, `:light_magenta`, `:light_white`.

  ### 256 color palette

  <img title="256 color palette" alt="palette image" src="assets/256_colors.png">

  ##  Example
      iex> "Lorem-Ipsum"
      ...> |> String.split("-")
      ...> |> Support.Debug.log(label: "Split return")
      ...> |> Enum.join()
      ...> |> String.downcase()
      Split return ──────────────────────────────── 2022-03-10 - 00:47:07.523741
      ["Lorem", "Ipsum"]
      ────────────────────────────────── ValiotApp v0.0.0 - LoremIpsumApp v0.0.0
      "loremipsum" # <- This is the actual pipeline return, besides de console print.
  """
  @spec log(input :: any, opt :: keyword) :: any
  def log(input, opt \\ []) do
    inspect_opt =
      if not @bw do
        [
          syntax_colors: Keyword.get(opt, :syntax_colors, @syntax_colors),
          pretty: true,
          width: Keyword.get(opt, :width, @width)
        ]
      else
        [
          pretty: true,
          width: Keyword.get(opt, :width, @width)
        ]
      end

    [
      header(opt),
      line(),
      inspect(input, inspect_opt),
      line(),
      footer(opt),
      line()
    ]
    |> Enum.join()
    |> IO.write()

    input
  end

  # === Private ================================================================

  defp line(), do: "\n"
  defp reset(), do: if not @bw, do: "\e[0m", else: ""
  defp bold(), do: if not @bw, do: "\e[1m", else: ""
  defp color(c), do: if not @bw, do: "\e[38;5;#{c}m", else: ""

  defp header(opt) when is_list(opt) do
    %{
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      microsecond: {microsecond, 6}
    } = NaiveDateTime.utc_now()

    label = Keyword.get(opt, :label)
    width = Keyword.get(opt, :width, @width)
    c0 = Keyword.get(opt, :color, "#{@color}")
    c1 = Keyword.get(opt, :line_color, "#{@line_color}")
    c2 = Keyword.get(opt, :time_color, "#{@time_color}")

    date =
      "#{year}"
      |> Kernel.<>("-")
      |> Kernel.<>(String.pad_leading("#{month}", 2, "0"))
      |> Kernel.<>("-")
      |> Kernel.<>(String.pad_leading("#{day}", 2, "0"))

    time =
      "#{hour}"
      |> String.pad_leading(2, "0")
      |> Kernel.<>(":")
      |> Kernel.<>(String.pad_leading("#{minute}", 2, "0"))
      |> Kernel.<>(":")
      |> Kernel.<>(String.pad_leading("#{second}", 2, "0"))
      |> Kernel.<>(".")
      |> Kernel.<>(String.pad_leading("#{microsecond}", 6, "0"))

    label = if !label, do: "", else: "#{label} "

    separation =
      width
      |> Kernel.-(String.length(label))
      |> Kernel.-(String.length(date))
      |> Kernel.-(String.length(time))
      |> Kernel.-(4)
      |> case do
        n when n > 0 -> n
        _ -> 0
      end

    label = "#{reset()}#{bold()}#{color(c0)}#{label}#{reset()}#{color(c1)}"
    date = "#{reset()}#{color(c2)}#{date}#{reset()}#{color(c1)}"
    time = "#{reset()}#{color(c2)}#{time}#{reset()}#{color(c1)}"

    color(c1)
    |> Kernel.<>(label)
    |> Kernel.<>(String.duplicate(@line_char, separation))
    |> Kernel.<>(" #{date} - #{time}")
    |> Kernel.<>(reset())
  end

  defp footer(opt) when is_list(opt) do
    width = Keyword.get(opt, :width, @width)
    c = Keyword.get(opt, :line_color, "#{@line_color}")

    version = "x" # Mix.Project.config()[:version]
    service = "x" # Mix.Project.config()[:app]

    sufix = " #{camelcase(service)} v#{version}"

    separation = width - String.length(sufix)

    color(c)
    |> Kernel.<>(String.duplicate(@line_char, separation))
    |> Kernel.<>(sufix)
    |> Kernel.<>(reset())
  end

  defp camelcase(input) when is_atom(input) do
    input |> Atom.to_string() |> camelcase()
  end

  defp camelcase(input) when is_binary(input) do
    input
    |> String.split(~r/-|_|\s/)
    |> Enum.map(fn e -> String.capitalize(e) end)
    |> Enum.join()
  end
end
