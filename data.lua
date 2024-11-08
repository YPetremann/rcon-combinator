local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({
  {
    type = "item",
    name = "rcon-combinator",
    icon = "__rcon-combinator__/graphics/icons/rcon-combinator.png",
    subgroup = "circuit-network",
    place_result = "rcon-combinator",
    order = "c[combinators]-r[rcon-combinator]",
    inventory_move_sound = item_sounds.combinator_inventory_move,
    pick_sound = item_sounds.combinator_inventory_pickup,
    drop_sound = item_sounds.combinator_inventory_move,
    stack_size = 50
  },
  {
    type = "recipe",
    name = "rcon-combinator",
    enabled = false,
    ingredients = {
      { type = "item", name = "copper-cable",       amount = 5 },
      { type = "item", name = "electronic-circuit", amount = 5 }
    },
    results = {
      { type = "item", name = "rcon-combinator", amount = 1 }
    }
  },
  {
    type = "constant-combinator",
    name = "rcon-combinator",
    icon = "__rcon-combinator__/graphics/icons/rcon-combinator.png",
    flags = { "placeable-neutral", "player-creation" },
    minable = { mining_time = 0.1, result = "rcon-combinator" },
    max_health = 120,
    corpse = "constant-combinator-remnants",
    dying_explosion = "constant-combinator-explosion",
    collision_box = { { -0.35, -0.35 }, { 0.35, 0.35 } },
    selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
    damaged_trigger_effect = hit_effects.entity(),
    fast_replaceable_group = "constant-combinator",
    open_sound = sounds.combinator_open,
    close_sound = sounds.combinator_close,
    icon_draw_specification = { scale = 0.7 },
    sprites = make_4way_animation_from_spritesheet({
      layers = {
        {
          filename = "__rcon-combinator__/graphics/entity/rcon-combinator.png",
          width = 114,
          height = 102,
          shift = util.by_pixel(0, 5),
          scale = 0.5,
        },
        {
          filename = "__rcon-combinator__/graphics/entity/rcon-combinator-shadow.png",
          width = 98,
          height = 66,
          shift = util.by_pixel(8.5, 5.5),
          scale = 0.5,
          draw_as_shadow = true
        }
      }
    }),
    activity_led_light = { intensity = 0, size = 1, color = { r = 1.0, g = 1.0, b = 1.0 } },
    activity_led_light_offsets = { { 0.296875, -0.40625 }, { 0.25, -0.03125 }, { -0.296875, -0.078125 }, { -0.21875, -0.46875 } },
    circuit_wire_max_distance = 9,
    activity_led_sprites = {
      north = util.draw_as_glow {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
        size = { 14, 12 },
        shift = util.by_pixel(9, -11.5)
      },
      east = util.draw_as_glow {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-E.png",
        size = { 14, 14 },
        shift = util.by_pixel(7.5, -0.5)
      },
      south = util.draw_as_glow {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-S.png",
        size = { 14, 16 },
        shift = util.by_pixel(-9, 2.5)
      },
      west = util.draw_as_glow {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-W.png",
        size = { 14, 16 },
        shift = util.by_pixel(-7, -15)
      }
    },
    circuit_wire_connection_points = {
      {
        shadow = { red = util.by_pixel(7, -6), green = util.by_pixel(23, -6) },
        wire = { red = util.by_pixel(-8.5, -17.5), green = util.by_pixel(7, -17.5) }
      },
      {
        shadow = { red = util.by_pixel(32, -5), green = util.by_pixel(32, 8) },
        wire = { red = util.by_pixel(16, -16.5), green = util.by_pixel(16, -3.5) }
      },
      {
        shadow = { red = util.by_pixel(25, 20), green = util.by_pixel(9, 20) },
        wire = { red = util.by_pixel(9, 7.5), green = util.by_pixel(-6.5, 7.5) }
      },
      {
        shadow = { red = util.by_pixel(1, 11), green = util.by_pixel(1, -2) },
        wire = { red = util.by_pixel(-15, -0.5), green = util.by_pixel(-15, -13.5) }
      }
    }
  }
})
