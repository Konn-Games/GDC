local fm = require "fullmoon"
local lsqlite3 = require "lsqlite3"
local dbm = fm.makeStorage("gdc/gameData.sqlite3")
if dbm:exec [[
CREATE TABLE IF NOT EXISTS Game (id INTEGER PRIMARY KEY, os TEXT);
]] ~= lsqlite3.OK then
    error("can't create tables: " .. dbm:errmsg())
end

local insertGameStmt = dbm:prepare("INSERT INTO Game (os) VALUES (?)")
fm.setRoute({ "/game_data", method = "POST" }, function(r)
    assert(string.sub(r.body, 1, 1) == "{" and string.sub(r.body, -1, -1) == "}", "corrupt data")
    local data = load("return" .. r.body)()
    if insertGameStmt:bind(1, data.os) ~= lsqlite3.OK then error("can't bind values: " .. dbm:errmsg()) end
    if insertGameStmt:step() ~= lsqlite3.DONE then error("can't execute prepared statement: " .. dbm:errmsg()) end
    insertGameStmt:reset()
    return true
end)

fm.setRoute({ "/game_data", method = "GET" }, function(r)
    if r.body ~= os.getenv("PASSWORD") then return false end
    local rows = {}
    for row in dbm:nrows("SELECT id, os FROM Game") do
        rows[#rows + 1] = row
    end
    return fm.serveContent("json", rows)
end)

fm.run()
