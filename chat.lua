local thread = require("thread")
local component = require("component")
local event = require("event")
local io = require("io")
local term = require("term")
local text = require("text")


local chat_port = 9999
local chat_name = "YOUR NAME HERE"

local m = component.modem
m.open(9999)

-- Print function comes from here:
-- https://github.com/OpenPrograms/Kenny-Programs/blob/master/OpenComputers/irc.lua
function print(message, overwrite)
  local w, h = component.gpu.getResolution()
  local line
  repeat
    line, message = text.wrap(text.trim(message), w, w)
    if not overwrite then
      component.gpu.copy(1, 1, w, h - 1, 0, -1)
    end
    overwrite = false
    component.gpu.fill(1, h - 1, w, 1, " ")
    component.gpu.set(1, h - 1, line)
  until not message or message == ""
end

timer = nil

res, err = pcall(function()
  term.clear()
  print("Chat v1")

  timer = event.timer(0.25, function()
    local res, _, from, port, _, user, msg = event.pull(0.05, "modem_message")
    if res ~= nil then
        s = "<"..user.."> "..msg
        print(s, true)
    end
  end, math.huge)

  while true do
    local w, h = component.gpu.getResolution()
    term.setCursor(1, h)
    term.write("> ")

    local line = term.read()
    line = text.trim(line)

    if line:lower() == "/exit" then
      break
    end

    m.broadcast(chat_port, chat_name, line)
    s = "<"..chat_name.."> "..line
    print(s, true)
  end
end)

if timer then
  event.cancel(timer)
end

if not res then
  error(err, 0)
end
return err