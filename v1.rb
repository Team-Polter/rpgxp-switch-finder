# This file is exactly how it appears in Luigi's Mansion: The Music Box's script editor.
# START:
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# DEBUGGING TOOL-
# Find Switch
# By ZZMario
# Version 1
# Usage:
#-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Replace Value A in the function called at the end of the script to the switch
# id you want to debug.  (Find where it's used in any map outputted to a terminal)
#-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Find where a switch is used in maps, only works if the game is ran from any
# terminal. Replace the switch id at the end of this script with the one you want
# to debug and it will output everywhere it's used in the terminal, won't output
# the data files which aren't all the helpful to me and Weeg so I made it output
# all the maps the switch is used in the editor terms (so like ./Intro/Intro)
# Yeah, enjoy!
# PS: Currently the command to use this feature is commented out,  meaning it won't
# do anything. This can easily be removed by just removing the #. Weeg and I know
# this but if you use this script you should probably know to do this, if you
# don't already
# --ZZMario
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=

def load_map_infos
  load_data("Data/MapInfos.rxdata")
end

def get_map_folder_path(map_infos, map_info)
  path = []
  current = map_info
  while current && current.parent_id != 0
    parent = map_infos[current.parent_id]
    break if parent.nil?
    path.unshift(parent.name)
    current = parent
  end
  path.empty? ? "" : path.join("/") + "/"
end

def find_switch_usage(switch_id)
  map_infos = load_map_infos
  found = false
  
  (1..99).each do |map_id|
    map_file = sprintf("Data/Map%03d.rxdata", map_id)
    next unless File.exist?(map_file)

    map = load_data(map_file)
    next if map.events.nil?

    map_info = map_infos[map_id]
    map_name = map_info ? map_info.name : "Unknown Map"
    map_folder = map_info ? get_map_folder_path(map_infos, map_info) : ""

    map.events.each do |event_id, event|
      event.pages.each do |page|
        if page.condition.switch1_valid && page.condition.switch1_id == switch_id
          puts "Switch #{switch_id} used in map #{map_id} (#{map_folder}#{map_name}) [#{map_file}] event #{event_id} page condition switch1"
          found = true
        end
        if page.condition.switch2_valid && page.condition.switch2_id == switch_id
          puts "Switch #{switch_id} used in map #{map_id} (#{map_folder}#{map_name}) [#{map_file}] event #{event_id} page condition switch2"
          found = true
        end

        page.list.each do |cmd|
          if cmd.code == 122 && cmd.parameters[0] == switch_id
            puts "Switch #{switch_id} controlled in map #{map_id} (#{map_folder}#{map_name}) [#{map_file}] event #{event_id}"
            found = true
          end
          if (cmd.code == 111 || cmd.code == 411) && cmd.parameters[0] == 0 && cmd.parameters[1] == switch_id
            puts "Switch #{switch_id} checked in conditional branch on map #{map_id} (#{map_folder}#{map_name}) [#{map_file}] event #{event_id}"
            found = true
          end
        end
      end
    end
  end
  
  puts "No usage found for switch #{switch_id}." unless found
end

#find_switch_usage(60)
