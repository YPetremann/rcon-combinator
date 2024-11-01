if script.active_mods["gvv"] then require("__gvv__.gvv")() end

local function get_issuer(event)
  return event.player_index and game.get_player(event.player_index) or rcon
end
local schema = "https://raw.githubusercontent.com/YPetremann/rcon-combinator/refs/heads/master/schema.json"

local function json_parse(str)
  local obj
  local _, err = pcall(function() obj = helpers.json_to_table(str) end)
  if err then error("JSON parse error: " .. err) end
  if obj["$schema"] and obj["$schema"] ~= schema then error("root.$schema shouldt equal " .. schema) end
  return obj
end
local function json_stringify(obj)
  local new_obj = { ["$schema"] = schema }
  for k, v in pairs(obj) do new_obj[k] = v end
  return helpers.table_to_json(new_obj)
end

local function protect(fn)
  return function(event)
    local issuer = get_issuer(event)
    local succeed, message = pcall(fn, event)
    if not message then return end
    if type(message) == "string" then
      if issuer.object_name == "LuaPlayer" then
        issuer.print(message)
      else
        issuer.print(json_stringify({ message = message }))
      end
    else
      if issuer.object_name == "LuaPlayer" then
        issuer.print(helpers.table_to_json({ groups = message }))
      else
        issuer.print(json_stringify({ groups = message }))
      end
    end
  end
end

commands.add_command("reload-mods", "reload mod scripts.", protect(function(event)
  game.reload_mods()
  return "Mods reloaded."
end))

local is_type = {
  ["item"] = true,
  ["fluid"] = true,
  ["virtual"] = true,
  ["entity"] = true,
  ["recipe"] = true,
  ["space-location"] = true,
  ["asteroid-chunk"] = true,
  ["quality"] = true
}
local function name_to_signal(name)
  local parts = {}
  for part in string.gmatch(name, "[^%.]+") do table.insert(parts, part) end
  if #parts == 1 then return "item", parts[1], "normal" end
  if #parts == 2 then
    if is_type[parts[1]] then return parts[1], parts[2], "normal" end
    return "item", parts[1], parts[2]
  end
  if #parts == 3 then return parts[1], parts[2], parts[3] end
  error("Invalid signal name: " .. name)
end

local function to_filters(group)
  local filters = {}
  for name, signal in pairs(group) do
    if type(name) == "string" and type(signal) == "number" then
      local type, name, quality = name_to_signal(name)
      local count = signal
      table.insert(filters, { min = count, value = { type = type, name = name, quality = quality } })
    elseif type(name) == "number" and type(signal) == "table" then
      local type, name, quality = signal.type or "item", signal.name, signal.quality or "normal"
      local count = signal.count == nil and 1 or signal.count
      table.insert(filters, { min = count, value = { type = type, name = name, quality = quality } })
    end
  end
  return filters
end
local function add_circuit_network(wires, ctrl_bhvr, connector_id)
  local wire = ctrl_bhvr.get_circuit_network(connector_id)
  if wire then table.insert(wires, wire) end
end
commands.add_command("rcon-input", "send signals from circuit to RCON.", protect(function(event)
  local auto_sections = true
  local sections = {}
  if event.parameter then
    local requests = json_parse(event.parameter).requests
    if #requests > 0 then
      auto_sections = false
      for _, name in ipairs(requests) do sections[name] = {} end
    end
  end

  -- read signals from the circuit
  for _, combinator in pairs(storage.combinators) do
    local ctrl_bhvr = combinator.control_behaviour
    local groups = {}
    if ctrl_bhvr and not ctrl_bhvr.enabled then
      for _, section in ipairs(ctrl_bhvr.sections) do
        if auto_sections then
          if section.is_manual and not sections[section.group] then sections[section.group] = {} end
        end
        if section.is_manual and sections[section.group] then
          table.insert(groups, section.group)
        end
      end
      if #groups > 0 then
        local circuit_networks = {}
        add_circuit_network(circuit_networks, ctrl_bhvr, defines.wire_connector_id.combinator_input_red)
        add_circuit_network(circuit_networks, ctrl_bhvr, defines.wire_connector_id.combinator_input_green)
        for _, group in ipairs(groups) do
          if not sections[group] then sections[group] = {} end
          local section = sections[group]
          for _, wire in ipairs(circuit_networks) do
            for _, wireSignal in ipairs(wire.signals) do
              local signal = wireSignal.signal
              local key = (signal.type or "item") .. "." .. signal.name .. "." .. (signal.quality or "normal")
              if not section[key] then section[key] = 0 end
              section[key] = section[key] + wireSignal.count
            end
          end
        end
      end
    end
  end
  return helpers.table_to_json({ ["$schema"] = schema, groups = sections })
end))

commands.add_command("rcon-output", "send signals from RCON to circuit.", protect(function(event)
  local groups = json_parse(event.parameter).groups
  if not groups then error("Must provide root.groups") end
  for name, group in pairs(groups) do
    if type(group) ~= "table" then error("groups[\"" .. name .. "\"] should be a table") end
    groups[name] = to_filters(group)
  end

  local error_message = "Errors:"
  for _, combinator in pairs(storage.combinators) do
    local control = combinator.control_behaviour
    if control and control.enabled then
      for _, section in ipairs(control.sections) do
        succeed, result = pcall(function()
          if not section.is_manual then return end
          if not groups[section.group] then return end
          section.filters = groups[section.group]
        end)
        if not succeed then error_message = error_message .. "\n-" .. result end
      end
    end
  end
  if error_message ~= "Errors:" then error(error_message) end
  return "combinators updated"
end))


local function on_init()
  storage.combinators = {}
end

local function on_built(event)
  local entity = event.entity
  local unit_number = entity.unit_number
  if entity.name ~= "rcon-combinator" then return end
  game.print("built " .. unit_number)
  script.register_on_object_destroyed(entity)

  local control_behavior = entity.get_or_create_control_behavior()
  storage.combinators[unit_number] = { control_behaviour = control_behavior }
end

local function on_destroy(event)
  local unit_number = event.useful_id
  if not storage.combinators[unit_number] then return end
  game.print("destroy " .. unit_number)
  storage.combinators[unit_number] = nil
end

script.on_init(on_init)
script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.on_space_platform_built_entity, on_built)
script.on_event(defines.events.script_raised_built, on_built)
script.on_event(defines.events.script_raised_revive, on_built)
script.on_event(defines.events.on_object_destroyed, on_destroy)
