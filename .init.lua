local fm = require "fullmoon"
local lsqlite3 = require "lsqlite3"
local dbm = fm.makeStorage("gameData.sqlite3")
if dbm:exec [[
CREATE TABLE IF NOT EXISTS Crash (id INTEGER PRIMARY KEY, message TEXT);
]] ~= lsqlite3.OK then
    error("can't create tables: " .. dbm:errmsg())
end

local randomInsertDStmt = dbm:prepare("INSERT INTO Crash (message) VALUES (?)")
fm.setRoute({ "/crash", method = "POST" }, function(r)
    if randomInsertDStmt:bind(1, r.body) ~= lsqlite3.OK then error("can't bind values: " .. dbm:errmsg()) end
    if randomInsertDStmt:step() ~= lsqlite3.DONE then error("can't execute prepared statement: " .. dbm:errmsg()) end
    randomInsertDStmt:reset()
    return true
end)

fm.setRoute({ "/crash", method = "GET" }, function()
    local rows = {}
    for row in dbm:nrows("SELECT id, message FROM Crash") do
        rows[#rows + 1] = row
    end
    return fm.serveContent("json", rows)
end)

local deleteCrashStmt = dbm:prepare("DELETE FROM Crash WHERE id=(?)")
fm.setRoute({ "/crash/:id", method = "DELETE" }, function(r)
    local id = r.params.id
    if deleteCrashStmt:bind(1, id) ~= lsqlite3.OK then error(dbm:errmsg()) end
    if deleteCrashStmt:step() ~= lsqlite3.DONE then error("can't execute prepared statement: " .. dbm:errmsg()) end
    deleteCrashStmt:reset()
    return true
end)

fm.setRoute({ "/game_data", method = "POST" }, function(r)
    assert(string.sub(r.body, 1, 1) == "{" and string.sub(r.body, -1, -1) == "}", "corrupt data")
    local data = load("return" .. r.body)()
    for key, value in pairs(data) do
        print(key, value)
    end
    return true
end)

fm.run()
