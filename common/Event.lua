---Event.lua


-- We agree that the events received by the script use the "EVENT" prefix.
-- Events sent to the UI by scripts use the "UI" prefix, and events sent to the
-- global use the "GLOBAL" prefix

---@class Event
local Event = {
    EVENT_EXIT_GAME = "EVENT_EXIT_GAME",
    EVENT_LEVEL_SELECT_PAGE_UP = "EVENT_LEVEL_SELECT_PAGE_UP",
    EVENT_LEVEL_SELECT_PAGE_DOWN = "EVENT_LEVEL_SELECT_PAGE_UP",
    UI_SHOW_LEVEL_SELECT_UI = "EVENT_SHOW_LEVEL_SELECT_UI",
    UI_HIDE_LEVEL_SELECT_UI = "EVENT_HIDE_LEVEL_SELECT_UI",
    UI_LOAD_UI_FADE_IN = "UI_LOAD_UI_FADE_IN",
    UI_LOAD_UI_FADE_OUT = "UI_LOAD_UI_FADE_OUT",
    UI_SHOW_LOAD_UI = "UI_SHOW_LOAD_UI",
    UI_HIDE_LOAD_UI = "UI_HIDE_LOAD_UI",
}
return Event
