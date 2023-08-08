defmodule WspaceUI.HTML.Rendering do
  @moduledoc """
  System tools used as helpers ni various modules around the application.
  """

  alias Phoenix.HTML.Tag

  @service_link_class  "service-link"
  @disabled_link_class "disabled-link"
  @dead_link_class "dead-link"
  @service_sufixes ["dash", "doc", "cover", "graphiql", "epub"]

  # On Docker, when the task timeout reaches cancels remaining tasks
  def render_services(input) when is_list(input) do
    services_data = introspect_data(input)

    services_status = services_data |> fetch_request_tasks() |> run_tasks()
    status =
      %{
        services: services_status,
        groups: groups_status(services_data, services_status)
      }

    render(services_data, status)
  end

  def render_setup_resourse(resourse) when is_atom(resourse) do
    :wspace_ui
    |> Application.get_env(:setup_properties)
    |> Map.fetch!(resourse)
    |> Jason.encode!(pretty: true)
  end

  # === Private ================================================================
  
  defp introspect_data(input) when is_list(input) do
    Enum.map(input, fn({type, spec}) ->
      case spec do
        # Content element
        spec when is_list(spec) -> {type, introspect_data(spec)}

        # String named content element
        {name, spec} when is_binary(name) and is_list(spec) ->
          {type, {name, introspect_data(spec)}}

        # Simpe element, atom, 2 strings params
        {id, param0, param1} ->
          service = param0
          href = param1
          config_key =
            case Atom.to_string(id) do
              string_id ->
                string_id
                |> String.split("_")
                |> List.last()
                |> case do
                  sufix when sufix in @service_sufixes ->
                    String.replace(string_id, "_#{sufix}", "")

                  _ -> string_id
                end
                |> String.to_existing_atom()
            end

          config =
            :wspace_ui
            |> Application.get_env(:services)
            |> Map.get(config_key)
            || raise RuntimeError, """
            Application config variable :#{config_key} not found.
            """

          ping_port =
            case Application.get_env(:wspace_ui, :workspace) do
              true  -> config.network_port
              false -> config.host_port
            end

          service = %{
            service: service,
            href: href,
            host: config.host,
            port: config.host_port,
            ping_task: ping_task(config.host, ping_port, href)
          }

          {type, {id, service}}
      end
    end)
  end

  defp ping_task(host, port, href) do
    url = "http://#{host}:#{port}#{href}"
    timeout = Application.get_env(:wspace_ui, :http_timeout)
    recv_timeout = Application.get_env(:wspace_ui, :http_recv_timeout)

    #TODO: Check why the httpoison nxdomain stops remaining requests
    Task.async(fn ->
      url
      |> HTTPoison.get([], [timeout: timeout, recv_timeout: recv_timeout])
      # |> Debug.log(label: "Response: #{url}", color: 4)
      |> case do
        {:ok, %{status_code: code}} -> {:ok, %{code: code}}
        other -> {:error, inspect(other)}
      end
    end)
  end

  defp fetch_request_tasks(input) do
    Enum.reduce(input, [], fn({type, spec}, acc) ->
      acc ++ case {type, spec} do
        # Content element
        {_type, spec} when is_list(spec) -> fetch_request_tasks(spec)

        # String named content element
        {_type, {name, spec}} when is_binary(name) and is_list(spec) ->
          fetch_request_tasks(spec)

        {:service, _spec} ->
          {service_id, %{ping_task: task}} = spec
          
          [{service_id, task}]
      end
    end)
  end

  defp run_tasks(input) do
    input
    |> Enum.map(fn({_service_id, task}) -> task end)
    |> Task.yield_many(
      Application.get_env(:wspace_ui, :task_timeout)
    )
    |> Enum.zip(input)
    |> Enum.map(fn({yielded_task, input_task}) ->
      {%Task{} = task, result} = yielded_task
      {service_id, ping_task} = input_task

      # if is_nil(result) do
      #   Debug.log(task == ping_task, label: "#{service_id}", color: 2)
      # end

      case task == ping_task do
        true ->
          {
            service_id,
            case result do
              nil                     -> :timeout # Task exited by timeout
              {:ok, ping_result} ->
                case ping_result do
                  {:ok, %{code: 200}} -> :up
                  {:ok, %{code: 308}} -> :up      # pgAdmin redirect
                  {:ok, %{code: 302}} -> :up      # Dashboard redirect
                  {:ok, %{code: 400}} -> :up      # graphiQL query error
                  {:ok, %{code: _}}   -> :error   # 404 error & anything else
                  {:error, _error}    -> :timeout
                end
            end
          }

        false ->
          raise RuntimeError, """
            Ping tasks does not match for service :#{service_id}
            """
      end
    end)
  end
  
  defp groups_status(input, services_status) do
    Enum.reduce(input, [], fn({type, spec}, acc) ->
      acc ++ case type do
        :row     -> groups_status(spec, services_status)
        :column  -> groups_status(spec, services_status)
        :group   ->
          {group_name, group_spec} = spec
          [{
            group_name,
            group_spec
            |> Enum.map(fn({:service, {service_id, _service}}) ->
              services_status[service_id]
            end)
            |> Enum.all?(&(&1 == :timeout))
            |> case do
              true  -> :ignore
              false -> :render
            end
          }]
      end
    end)
  end

  defp render(input, status) when is_list(input) do
    input
    |> Enum.map(fn({type, spec}) ->
      case type do
        :row ->
          Tag.content_tag :section, class: "row" do render(spec, status) end

        :column ->
          Tag.content_tag :article, class: "column" do render(spec, status) end

        :group   ->
          {group_name, group_spec} = spec

          status.groups
          |> Map.new()
          |> Map.fetch!(group_name)
          |> case do
            #TODO: Check why the httpoison nxdomain stops remaining requests
            # :ignore -> nil
            # :render ->
            _ ->
              [
                Tag.content_tag :h3 do group_name end,
                Tag.content_tag :ul do render(group_spec, status) end
              ]
          end

        :service ->
          {service_id, service} = spec

          class =
            # # TODO: Check why the httpoison nxdomain stops remaining requests
            # case status.services[service_id] do
            #   :up      -> "#{@service_link_class}"
            #   :error   -> "#{@service_link_class} #{@disabled_link_class}"
            #   :timeout -> nil
            # end
            "#{@service_link_class}"

          if not is_nil(class) do
            Tag.content_tag :li do
              [
                Tag.content_tag :a,
                  href: service.href,
                  port: service.port,
                  target: "_blank",
                  class: class
                do
                  service.service
                end,
                Tag.content_tag :div, class: "service-url" do
                  "#{service.host}:#{service.port}#{service.href}"
                end
              ]
            end
          end
      end
    end)
    |> Enum.reject(&(is_nil(&1)))
  end
  
  # Be careful, this will receive all messages sent
  # to this process. It will return the first task
  # reply and the list of tasks that came second.
  defp await_first(tasks) do
    receive do
      message ->
        case Task.find(tasks, message) do
          {reply, task} ->
            List.delete(tasks, task)
            reply

          nil -> await_first(tasks)
        end
    end
  end
end
