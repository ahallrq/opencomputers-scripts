local thread = require("thread")
local component = require("component")
local event = require("event")
local io = require("io")
local term = require("term")
local text = require("text")
local computer = require("computer")

local chat_port = 9999
local chat_name = "YOUR NAME HERE"
local chat_notify = true

local m = component.modem
m.open(9999)

-- Simple lock

SimpleLock = { isLocked = 0,
  get = function (self)
          if self.isLocked == 0 then
            self.isLocked = 1
          else
            repeat
              os.sleep(0.01)
            until self.isLocked == 0
          end
        end,
  release = function (self)
              if self.isLocked == 0 then
                error("Lock has already been released!")
              else
                self.isLocked = 0
              end
            end
}

--

-- Print function comes from here:
-- https://github.com/OpenPrograms/Kenny-Programs/blob/master/OpenComputers/irc.lua
function print(message, overwrite)
  SimpleLock:get()
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
  SimpleLock:release()
end

t = nil

res, err = pcall(function()
  term.clear()
  print("Chat v1")

  t = thread.create(function()
    while true do
        local res, _, from, port, _, user, msg = event.pull("modem_message")
        if res ~= nil then
            s = "<"..user.."> "..msg
            print(s)
            if chat_notify then
                for i=1,3 do
                  computer.beep(500, 0.05)
                end
            end
        end
        os.sleep(0.05)
    end
  end)

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
  t:kill()
end

if not res then
  error(err, 0)
end
return err
