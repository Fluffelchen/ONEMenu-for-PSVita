--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

__SLIDES = tonumber(ini.read(__PATH_INI,"slides","pos",100))
__PIC1   = tonumber(ini.read(__PATH_INI,"pics","show","0"))

theme = {
	data = {},	-- Handle of imgs
	style = {},	-- Handle of colors
}

function theme.load()

	-- Get the id of theme pack
	__THEME = ini.read(__PATH_INI,"theme","id","default")
	__BACKG = ini.read(__PATH_INI,"backg","img","")
	__FNT = tonumber(ini.read(__PATH_INI,"font","type","2"))

	local elements = {

		{name="list"},
		{name="icons",sprite=true, w=16,h=16},    -- 112x16
		{name="buttons1",sprite=true, w=20,h=20}, -- 120*20
		{name="buttons2",sprite=true, w=30,h=20}, -- 120*20
		{name="wifi",sprite=true, w=22,h=22},     -- 132*22

		{name="psvita"},
		{name="hbvita"},
		{name="psm"},
		{name="retro"},
		{name="adrbb"},

		{name="icodef"},

		{name="jump", sound=true},
		{name="slide", sound=true},
	}

	local path_theme = __PATH_THEMES..__THEME.."/"
	if not files.exists(path_theme) then path_theme = "system/theme/default/" end

	--Primero checamos si tienen una img de fondo para el back
	theme.data["back"] = image.load(__BACKG)
	if not theme.data["back"] then theme.data["back"] = image.load(path_theme.."back.png") or image.load("system/theme/default/back.png") end

	if theme.data["back"] then 
		if (image.getrealw(theme.data["back"]) < __DISPLAYW or image.getrealh(theme.data["back"]) < __DISPLAYH) or
			(image.getrealw(theme.data["back"]) > __DISPLAYW or image.getrealh(theme.data["back"]) > __DISPLAYH) then
			theme.data["back"]:resize(__DISPLAYW, __DISPLAYH)
		end
	end

	-- Load Resources
	local path_resources = "system/theme/default/"
	for i=1,#elements do
		if files.exists(string.format("%s%s.png",path_theme,elements[i].name)) or files.exists(string.format("%s%s.ogg",path_theme,elements[i].name)) then
			path_resources = path_theme else path_resources = "system/theme/default/" end

		if elements[i].sound then
			theme.data[elements[i].name] = sound.load(string.format("%s%s.ogg",path_resources,elements[i].name))--,1)
		elseif elements[i].sprite then
			theme.data[elements[i].name] = image.load(string.format("%s%s.png",path_resources,elements[i].name),elements[i].w,elements[i].h)
		else
			theme.data[elements[i].name] = image.load(string.format("%s%s.png",path_resources,elements[i].name))
		end
	end

	--Colores por defecto = tema por default
	theme.style = {
		TXTCOLOR		= 0xFFFFFFFF,
		TXTBKGCOLOR		= 0xFF000000,
		BARCOLOR        = 0x64970D0E,
		TITLECOLOR      = 0xFF9999FF,
		PATHCOLOR       = 0xFFFF76CA,
		DATETIMECOLOR   = 0x64F36B0E,
		COUNTCOLOR		= 0XFF0000FF,
		CBACKSBARCOLOR	= 0x64FFFFFF,
		SELCOLOR        = 0x6433C95E,
		SFOCOLOR        = 0XFFFF07FF,
		BINCOLOR        = 0XFF1D62EC,
		MUSICCOLOR      = 0xFFFFFF00,
		IMAGECOLOR      = 0xFF00FF00,
		ARCHIVECOLOR    = 0xFFFFFF00,
		MARKEDCOLOR     = 0x2AEDEEFF,
		FTPCOLOR		= 0x64F36B0E,
		PERCENTCOLOR	= 0xFFFF76CA,
		BATTERYCOLOR	= 0x6453CE43,
		LOWBATTERYCOLOR	= 0xFF0000B3,
		GRADRECTCOLOR	= 0x64970D0E,
		GRADSHADOWCOLOR = 0xC8F36B0E,
	}

	function parseTheme(filename,default)
		for line in io.lines(filename) do
			if not line:find("#") and not (line:len()==0) then --ignorar líneas con # o en blanco
				local k,v = line:match("(.+)=(.+)")
					if tonumber(v) then --filtrar valores no numéricos
						local tmpk=""
							for i=1,k:len() do if string.byte(k:sub(i,i))>47 then tmpk=tmpk..k:sub(i,i) end end --limpieza de index!
						default[tmpk] = tonumber(v) --No hace falta limpiar el valor, se limpia solo
					end
			end
		end
	end

	parseTheme(path_theme.."theme.ini",theme.style)

	fnt, __USERFNT = nil,false
	if files.exists(string.format("%s%s",path_theme,"font.ttf")) then
		fnt = font.load(string.format("%s%s",path_theme,"font.ttf"))
	elseif files.exists(string.format("%s%s",path_theme,"font.pgf")) then
		fnt = font.load(string.format("%s%s",path_theme,"font.pgf"))
	elseif files.exists(string.format("%s%s",path_theme,"font.pvf")) then
		fnt = font.load(string.format("%s%s",path_theme,"font.pvf"))
	end

	if fnt then	font.setdefault(fnt)
		__USERFNT = true
	else font.setdefault(__FNT) end

	icons_mimes={ 1,pbp=2,prx=2,bin=2,suprx=2,skprx=2,dat=2,db=2,a=2,prs=2,pmf=2,at9=2,dds=2,tmp=2,html=2,gft=2,sfm=2,icv=2,cer=2,dic=2,pgf=2,
					rsc=2,rco=2,res=2,dreg=2,ireg=2,pdb=2,mai=2,bin_bak=2,psp2dmp=2,rif=2,trp=2,self=2,mp4=2,edat=2,log=2,ptf=2,ctf=2,inf=2,
					png=3,gif=3,jpg=3,bmp=3,
					mp3=4,s3m=4,wav=4,at3=4,ogg=4,
					rar=5,zip=5,vpk=5,gz=5,
					cso=6,iso=6,dax=6
				}

	isopened = { png = theme.style.IMAGECOLOR, jpg = theme.style.IMAGECOLOR, gif = theme.style.IMAGECOLOR, bmp = theme.style.IMAGECOLOR,
				 mp3 = theme.style.MUSICCOLOR, ogg = theme.style.MUSICCOLOR, wav = theme.style.MUSICCOLOR,
				 iso = theme.style.BINCOLOR, pbp = theme.style.BINCOLOR, cso = theme.style.BINCOLOR, dax = theme.style.BINCOLOR, bin = theme.style.BINCOLOR, suprx = theme.style.BINCOLOR, skprx = theme.style.BINCOLOR,
				 zip = theme.style.ARCHIVECOLOR, rar = theme.style.ARCHIVECOLOR, vpk = theme.style.ARCHIVECOLOR, gz = theme.style.ARCHIVECOLOR,
				 sfo = theme.style.SFOCOLOR,
			}
end

function reload_theme()

	write_config()

	local vbuff = screen.toimage()
	local titlew = string.format(strings.wait)
	local w,h = screen.textwidth(titlew,1) + 30,70
	local x,y = 480 - (w/2), 272 - (h/2)

	if vbuff then vbuff:blit(0,0) end
	draw.fillrect(x,y,w,h,theme.style.BARCOLOR)
	draw.rect(x,y,w,h,color.white)
		screen.print(480,y+13,titlew,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
	screen.flip()

	theme.data = {}
	theme.style = {}
	collectgarbage("collect")
	os.delay(2000)

	theme.load()

	--RE-Load Slides
	categories = {
		{ img = theme.data["psvita"] },	--cat 1
		{ img = theme.data["hbvita"] },	--cat 2
		{ img = theme.data["psm"] },	--cat 3
		{ img = theme.data["retro"]},	--cat 4
		{ img = theme.data["adrbb"]},	--cat 5
	}

	--Asignamos limites y las img para nuestras categorias
	for i=1,#appman do
		appman[i].slide.img = categories[i].img
		if appman[i].slide.img then
			appman[i].slide.w = appman[i].slide.img:getw()
		end
	end
end

-- Thread Theme Vars
THEME_PORT_I = channel.new("THEME_PORT_I")
THEME_PORT_O = channel.new("THEME_PORT_O")
THID_THEME = thread.new("system/thread_theme.lua")

function theme.manager()
	
	local list = { {}, {} } -- 1 local - 2 remote

	local tmp = files.listdirs(__PATH_THEMES)
	if tmp and #tmp > 0 then
		for i=1,#tmp do
			local title = ini.read(tmp[i].path.."/theme.ini","TITLE","Unknow")
			local author = ini.read(tmp[i].path.."/theme.ini","AUTHOR","Unknow")
			local preview = image.load(tmp[i].path.."/preview.png")
			if preview then preview:resize(252,151) end
			table.insert(list[1], {id=tmp[i].name, title = title, author = author, preview = preview})
		end
	end
	tmp = nil
	collectgarbage("collect")
	table.insert(list[1], 1, {id="", title = strings.search, author = "", preview = nil, ext = true})

	local scr = { newScroll(list[1],15), newScroll(list[2],15) }
	local sect = 1
	local themesimg = image.load(__PATH_THEMES..__THEME.."/themesmanager.png") or image.load("system/theme/default/themesmanager.png")
	local changes = false

	while true do
		buttons.read()
		if themesimg then themesimg:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
		
		screen.print(480,15,({strings.themes, strings.themesonline })[sect],1,theme.style.TITLECOLOR,color.gray,__ACENTER)
		local y = 70
		for i=scr[sect].ini,scr[sect].lim do
			if i == scr[sect].sel then
				if list[sect][i].preview then
					list[sect][i].preview:blit(700,84)
				else
					draw.fillrect(700,84, 252,151, color.shine)
					if sect == 2 then
						if THEME_PORT_I:available() > 0 then
							local entry = THEME_PORT_I:pop()
							list[2].mask[entry.id].preview = entry.icon;
						end
					end
				end
				screen.print(700+126,240,list[sect][i].author or "unk",1.0,theme.style.TITLECOLOR,color.gray,__ACENTER)
				draw.fillrect(5,y-3,680,25,theme.style.SELCOLOR)
			end 
			screen.print(20,y,list[sect][i].title,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
			y+=26
		end

		screen.print(15,520,strings.themeactual..__THEME,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)

		if theme.data["buttons2"] then
			theme.data["buttons2"]:blitsprite(960-30,515,1)--start
		end
		screen.print(960-40,520,strings.reload,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)
	
		screen.flip()

		if buttons.start and __THEME != "default" then
			__THEME = "default"
			__BACKG = ""
			reload_theme()
			themesimg = image.load(__PATH_THEMES..__THEME.."/themesmanager.png") or image.load("system/theme/default/themesmanager.png")
		end
		
		if buttons.up or buttons.analogly < -60 then scr[sect]:up() end
		if buttons.down or buttons.analogly > 60 then scr[sect]:down() end

		if buttons[accept] then
			if sect == 1 then
				if not list[sect][scr[sect].sel].ext and list[sect][scr[sect].sel].id != __THEME then
					__THEME = list[sect][scr[sect].sel].id
					__BACKG = ""
					reload_theme()
					themesimg = image.load(__PATH_THEMES..__THEME.."/themesmanager.png") or image.load("system/theme/default/themesmanager.png")
				elseif list[sect][scr[sect].sel].ext then

					local vbuff = screen.toimage()
					if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
					message_wait()
					os.delay(15)

					-- Call Download themes...
					local onNetGetFileOld = onNetGetFile; onNetGetFile = nil
					local raw = http.get(string.format("https://raw.githubusercontent.com/%s/%s/master/Themes/database.json", APP_REPO, APP_PROJECT))
					onNetGetFile = onNetGetFileOld
					if raw then
						local not_err = true
						not_err, list[2] = pcall(json.decode, raw)
						if not_err then
							sect = 2
							list[2].mask = {}
							scr[2]:set(list[2], 15)
							local j = 1
							while list[2][j] do list[2].mask[list[2][j].id] = list[2][j]; THEME_PORT_O:push({id = list[2][j].id}); j+=1; end
						else
							os.message(strings.errordecode)
						end
					else
						os.message(strings.errorgetbase)
					end
					os.delay(15)
					if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
				end
			elseif files.exists(string.format("%s%s",__PATH_THEMES,list[sect][scr[sect].sel].id)) == false or os.message(list[sect][scr[sect].sel].id.." "..strings.themeisready, 1) == 1 then --sect == 2

				local vbuff = screen.toimage()
				if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
				message_wait()
				os.delay(15)

				local url = string.format("https://raw.githubusercontent.com/%s/%s/master/Themes/%s.zip", APP_REPO, APP_PROJECT, list[sect][scr[sect].sel].id)
				local path = string.format("ux0:data/ONEMENU/tmp/%s.zip", list[sect][scr[sect].sel].id)
				if http.getfile(url, path) then
					if files.extract(path, __PATH_THEMES) == 1 then
						changes = true
						os.message(strings.themeinstall)
					else
						os.message(strings.errorunpack)
					end
					files.delete(path)
				else
					os.message(strings.notdown)
				end
				os.delay(15)
				if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			end
		end

		if buttons[cancel] then
			local vbuff = screen.toimage()
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
			if sect == 1 then
				break
			else
				sect = 1
				if changes then
					list[1] = nil
					collectgarbage("collect")
					list[1] = {}
					local tmp = files.listdirs(__PATH_THEMES)
					if tmp and #tmp > 0 then
						for i=1,#tmp do
							local title = ini.read(tmp[i].path.."/theme.ini","TITLE","Unknow")
							local author = ini.read(tmp[i].path.."/theme.ini","AUTHOR","Unknow")
							local preview = image.load(tmp[i].path.."/preview.png")
							if preview then preview:resize(252,151) end
							table.insert(list[1], {id=tmp[i].name, title = title, author = author, preview = preview})
						end
					end
					tmp = nil
					collectgarbage("collect")
					table.insert(list[1], 1, {id="", title = strings.search, author = "", preview = nil, ext = true})
					scr[1]:set(list[1],15)
				end
				changes = false
			end
			os.delay(15)
			if vbuff then vbuff:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
		end
	end
end

--Load our theme
theme.load()
