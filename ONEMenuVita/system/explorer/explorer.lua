--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

-- Create two scrolls :P
scroll = {
   list = newScroll(),
   menu = newScroll(),
}

xtitle,movx = 35,0
title_scr_x = 5
maxim_files=16
backl, explorer, multi = {},{},{} -- All explorer functions
slidex=0

-- ## Explorer Drawer List ## --
function explorer.listshow(posy)

	if movx==0 then	len_selector,len_clip = __DISPLAYW-25,500 else len_selector,len_clip = __DISPLAYW-173,600 end

	if menu_ctx.close and slidex > 0 then slidex -= 10 end
	if not menu_ctx.close and slidex < 86 then slidex += 10 end

	for i=scroll.list.ini, scroll.list.lim do

		if i==scroll.list.sel then
			ccc = theme.style.TXTBKGCOLOR--color.green:a(130)
			draw.fillrect(5+movx, posy-3, len_selector, 23, theme.style.SELCOLOR)

			if screen.textwidth(explorer.list[i].name or "",1) > len_clip then 
				xtitle = screen.print( xtitle+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or
									   theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __SLEFT, len_clip)
				xtitle -= movx
			else
				screen.clip(35+movx,0,len_clip+movx,544)
				screen.print(35+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)
				xtitle=35
			end
		else
			ccc = theme.style.TXTBKGCOLOR
			screen.clip(35+movx,0,len_clip+movx,544)
			screen.print(35+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR, __ALEFT)
		end
		screen.clip()

		if explorer.list[i].size then
			if icons_mimes[explorer.list[i].ext] then theme.data["icons"]:blitsprite(10+movx, posy, icons_mimes[explorer.list[i].ext]) -- mime type
			else theme.data["icons"]:blitsprite(10+movx, posy, 0) end -- file unk
		else
			theme.data["icons"]:blitsprite(10+movx, posy, 1) -- folder 
		end

		if explorer.list[i].multi then draw.fillrect(5+movx, posy-3, len_selector, 22, theme.style.MARKEDCOLOR) end

		screen.print((680+movx)+slidex, posy, explorer.list[i].size or "<DIR>", 1, theme.style.TXTCOLOR,ccc, __ARIGHT)
		screen.print((930+movx)+slidex, posy, explorer.list[i].mtime, 1.0, theme.style.TXTCOLOR,ccc, __ARIGHT)
		posy += 26

	end--for

end

--Cycle Main for Explorer Files: show_explorer_list()
local xtmp = 0
function show_explorer_list(first_path)

	explorer.refresh(true,first_path)
	buttons.interval(16,5)
	while true do

		buttons.read()
		if theme.data["list"] then theme.data["list"]:blit(0,0) end

		movx = menu_ctx.x + menu_ctx.w

		if screen.textwidth(Root[Dev] or "",1) > 860 then 
			title_scr_x = screen.print(title_scr_x+movx,5,Root[Dev],1,theme.style.PATHCOLOR,color.black,__SLEFT,860)
			title_scr_x -= movx
		else
			screen.print(5+movx,5,Root[Dev],1,theme.style.PATHCOLOR,color.black,__ALEFT)
			title_scr_x = 5
		end

		if infosize then
			xtmp = screen.print(5+movx,33,files.sizeformat(infosize.max or 0).."/"..files.sizeformat(infosize.free or 0),1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		end

		--Partitions
		if menu_ctx.close then
			local xRoot = xtmp + 15
			local w = (955-xRoot)/#Root2
			for i=1, #Root2 do
				if Dev == i then
					draw.fillrect(xRoot,28,w,28, theme.style.SELCOLOR)
				end
				screen.print(xRoot+(w/2), 33, Root2[i], 1, color.white, 0x0, __ACENTER)
				xRoot += w
			end
		end

		screen.print(940+movx,5,scroll.list.maxim,1,theme.style.COUNTCOLOR,theme.style.TXTBKGCOLOR,__ARIGHT)

		if (multi and #multi > 0) and action then
			if movx==0 then
				screen.print(940-movx,515,STRINGS_SEL_ITEMS+#multi,1,color.new(255,69,0),color.black,__ARIGHT)
			else
				screen.print((940-movx)+160,515,STRINGS_SEL_ITEMS+#multi,1,color.new(255,69,0),color.black,__ARIGHT)
			end
		end

		--Bar Scroll
		local y,h=70, (maxim_files*26)-2
		if scroll.list.maxim > 0 then
			draw.fillrect(945+movx, y-2, 8, h, color.shine)
			if scroll.list.maxim >= maxim_files then -- Draw Scroll Bar
				local pos_height = math.max(h/scroll.list.maxim, maxim_files)
				draw.fillrect(945+movx, y-2 + ((h-pos_height)/(scroll.list.maxim-1))*(scroll.list.sel-1), 8, pos_height, color.new(0,255,0))
			end
			explorer.listshow(y)
		else
			screen.print(10+movx,80,"...".."\n\n"..STRINGS_BACK,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR)
		end

		screen.print(10+movx,515,os.date(_time.." %m/%d/%y").."  "..batt.lifepercent().."%",1,theme.style.DATETIMECOLOR,color.gray,__ALEFT)

		menu_ctx.run()

		screen.flip()

		ctrls_explorer_list()
	end

end

function explorer.refresh(onflag,first_path)
	if onflag then infosize = os.devinfo(Root2[Dev]) end
	explorer.list = files.listsort(first_path or Root[Dev])
	scroll.list:set(explorer.list,maxim_files)
	if first_path then Root[Dev]=first_path end
end

function ctrls_explorer_list()

	if menu_ctx.open then return end
	if not menu_ctx.close then return end

	if buttons[cancel] then -- return directory

		if check_root() then return end

		Root[Dev]=files.nofile(Root[Dev])
		explorer.refresh(false)

		if #backl>0 then
			if scroll.list.maxim == backl[#backl].maxim then
				scroll.list.ini = backl[#backl].ini
				scroll.list.lim = backl[#backl].lim
				scroll.list.sel = backl[#backl].sel
			end
			backl[#backl] = nil
		end
	end

	if scroll.list.maxim > 0 then -- Is exists any?
		if buttons.up or buttons.analogly < -60 then scroll.list:up() end
		if buttons.down or buttons.analogly > 60 then scroll.list:down() end

		if buttons[accept] then
			if explorer.list[scroll.list.sel].size then
				handle_files(explorer.list[scroll.list.sel])
			else
				table.insert(backl, {maxim = scroll.list.maxim, ini = scroll.list.ini, sel = scroll.list.sel, lim = scroll.list.lim, })
				Root[Dev]=explorer.list[scroll.list.sel].path
				explorer.refresh(false)
			end
		end
	end

	-- Switch device
	if buttons.released.r or buttons.released.l then
		if menu_ctx.open then return end
		if buttons.released.l then Dev -= 1 else Dev += 1 end

		if Dev > #Root then Dev = 1 end
		if Dev < 1 then Dev = #Root end
		os.delay(10)
		explorer.refresh(true)
	end

	-- Multi-Selection
	if buttons.square then
		explorer.list[scroll.list.sel].multi = not explorer.list[scroll.list.sel].multi
		if explorer.list[scroll.list.sel].multi then
			table.insert(multi, explorer.list[scroll.list.sel].path)
			explorer.list[scroll.list.sel].index = #multi
		else
			table.remove(multi, explorer.list[scroll.list.sel].index)
		end
	end

	--Return AppManager
	if buttons.select and menu_ctx.open==false then
		submenu_ctx.close = true
		restart_cronopic()
		appman.launch()
	end

	shortcuts()

end

function handle_files(cnt)
	local extension = cnt.ext

	if extension == "png" or extension == "jpg" or extension == "bmp" or extension == "gif" then
		visorimg(cnt.path)
	elseif extension == "vpk" then
		buttons.homepopup(0)
			show_msg_vpk(cnt)
			if vpkdel then explorer.refresh(true) end
		buttons.homepopup(1)
	elseif extension == "zip" or extension == "rar" then
		show_scan(cnt)
	elseif extension == "pbp" or extension == "iso" or extension == "cso" then
		show_msg_pbp(cnt)
	elseif extension == "mp3" or extension == "wav" or extension == "ogg" then
		MusicPlayer(cnt)
	elseif extension == "txt" or extension == "lua" or extension == "ini" or extension == "sfo" or extension == "xml" or extension == "inf" or extension == "cfg" then
		visortxt(cnt,true)
	end

end

---------------------------------- SubMenu Contextual 1 ---------------------------------------------------

__ACTION_WAIT_NOTHING = 0
__ACTION_WAIT_PASTE = 1
__ACTION_WAIT_EXTRACT = 2
 
local src_path_callback = function ()
   if #explorer.list > 0 then
      local ext = explorer.list[scroll.list.sel].ext or ""
      if menu_ctx.scroll.sel != 3 or (menu_ctx.scroll.sel == 3 and (ext:lower()=="zip" or ext:lower()=="rar" or ext:lower()=="vpk")) then
         if not multi or #multi < 1 then
            table.insert(multi, explorer.list[scroll.list.sel].path)
         end
         explorer.action = menu_ctx.scroll.sel
 
         if menu_ctx.scroll.sel != 3 then menu_ctx.wait_action = __ACTION_WAIT_PASTE else menu_ctx.wait_action = __ACTION_WAIT_EXTRACT end
         menu_ctx.wakefunct()
    	 menu_ctx.close = true
         action = true
      end
   end
end

local paste_callback = function ()
    explorer.dst = Root[Dev]
 
    if explorer.action == 1 then                        --Paste from Copy
        if #multi>0 then
            buttons.homepopup(0)
            reboot=false
            for i=1,#multi do
                files.copy(multi[i],explorer.dst)
            end
            buttons.homepopup(1)
            reboot=true
        end
 
    elseif explorer.action == 2 then                     --Paste from Move
        if #multi>0 then
            reboot=false
            local _dst = explorer.dst:sub(1,3)
            for i=1,#multi do
                if multi[i]:sub(1,3) == _dst then
                    files.move(multi[i],explorer.dst)
                else
                    buttons.homepopup(0)
                    if files.copy(multi[i],explorer.dst)==1 then files.delete(multi[i]) end
                    buttons.homepopup(1)
                end
            end
            reboot=true
        end
 
    elseif explorer.action == 3 then                     --Extract
        if #multi>0 then
            reboot=false
            for i=1,#multi do
                if os.message(multi[i]+"\n\n"+STRINGS_PASS ,1)==1 then
                    local pass = osk.init(STRINGS_OS_PASS , "" , 50, __OSK_TYPE_LATIN, __OSK_MODE_PASSW)
                    if pass then
                        buttons.homepopup(0)
                            files.extract(multi[i],explorer.dst,pass)
                        buttons.homepopup(1)
                    end
                else
                    buttons.homepopup(0)
                        files.extract(multi[i],explorer.dst)
                    buttons.homepopup(1)
                end
            end
            reboot=true
        end
    end
 
--clean
    menu_ctx.wakefunct()
    menu_ctx.close = true
    action = false
    explorer.refresh(true)
    explorer.action = 0
	menu_ctx.wait_action = __ACTION_WAIT_NOTHING
    explorer.dst = ""
    multi={}
end
 
local delete_callback = function () -- TODO: add move to -1 pos of the deleted element in list
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	local pos_menu = menu_ctx.scroll.sel

    if #explorer.list > 0 then
		local del=false
        if explorer.list[scroll.list.sel].multi then
            if #multi>0 then
                if os.message(STRINGS_SUBMENU_DELETE.." "..#multi.."\n\n"..STRINGS_FILES_FOLDERS.."(s) ?",1) == 1 then
					del=true
                    reboot=false
                        for i=1,#multi do files.delete(multi[i]) end
                    reboot=true
                end
            end
        else
            if os.message(STRINGS_SUBMENU_DELETE.."\n\n"..explorer.list[scroll.list.sel].path.." ?",1) == 1 then
				del=true
                reboot=false
                    files.delete(explorer.list[scroll.list.sel].path)
                reboot=true
            end
        end
		if del then
--clean
			menu_ctx.wakefunct()
			menu_ctx.close = true
			action = false
			explorer.refresh(true)
			explorer.action = 0
			multi={}
		end
	end

	menu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

local rename_callback = function ()
    if #explorer.list > 0 then
        local new_name = osk.init(STRINGS_SUBMENU_RENAME, files.nopath(explorer.list[scroll.list.sel].path), 256, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
        if new_name then
            local fullpath = files.nofile(explorer.list[scroll.list.sel].path)
            files.rename(explorer.list[scroll.list.sel].path, new_name)
            --explorer.list[scroll.list.sel].path = fullpath+new_name
            --explorer.list[scroll.list.sel].name = new_name
            --explorer.list[scroll.list.sel].ext = files.ext(new_name)
--clean
            menu_ctx.wakefunct()
            menu_ctx.close = true
            action = false
            explorer.action = 0
			multi={}
			explorer.list = files.listsort(Root[Dev])
        end
    end
end

local newfile_callback = function () -- Added suport multi-new-folder
    local i=1
    while files.exists(Root[Dev].."/"..string.format("%s%03d",STRINGS_NEW_FILE,i)) do
        i+=1
    end
    local name_folder = osk.init(STRINGS_CREAT_FILE, string.format("%s%03d",STRINGS_NEW_FILE,i), 256, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
    if name_folder then
        local dest = Root[Dev].."/"..name_folder
        if Root[Dev]:sub(#Root[Dev]) == "/" then dest = Root[Dev]..name_folder end
        files.new(dest)
--clean
        menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
        multi={}
    end
end
 
local makedir_callback = function () -- Added suport multi-new-folder
    local i=1
    while files.exists(Root[Dev].."/"..string.format("%s%03d",STRINGS_NEW_FOLDER,i)) do
        i+=1
    end
    local name_folder = osk.init(STRINGS_CREAT_FOLDER, string.format("%s%03d",STRINGS_NEW_FOLDER,i), 256, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
    if name_folder then
        local dest = Root[Dev].."/"..name_folder
        if Root[Dev]:sub(#Root[Dev]) == "/" then dest = Root[Dev]..name_folder end
        files.mkdir(dest)
--clean
        menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
        multi={}
    end
end
 
local sizedir_callback = function ()
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	local pos_menu = menu_ctx.scroll.sel
	local sizedir=0

	if #explorer.list > 0 then
		if explorer.list[scroll.list.sel].multi then
			if #multi>0 then
				sizedir=0
				message_wait()
				for i=1,#multi do
					sizedir += files.size(multi[i])
				end--for
				os.message(STRINGS_CALLBACKS_SIZE_ALL.." "..files.sizeformat(sizedir or 0))
			end
		else
			if not explorer.list[scroll.list.sel].size then                -- Its Dir
				message_wait()
				os.message(explorer.list[scroll.list.sel].name+"\n\n"+STRINGS_SIZE_IS+files.sizeformat(files.size(explorer.list[scroll.list.sel].path) or 0))
			else
				os.message(explorer.list[scroll.list.sel].name+"\n\n"+STRINGS_SIZE_IS+explorer.list[scroll.list.sel].size)
			end
		end
    end
	sizedir=0
	menu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

local installgame_callback = function ()
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
    if #explorer.list > 0 then
        if explorer.list[scroll.list.sel].ext == "vpk" then
            buttons.homepopup(0)
                show_msg_vpk(explorer.list[scroll.list.sel])
            buttons.homepopup(1)
            return
        end
 
        if not files.exists(string.format("%s/eboot.bin",explorer.list[scroll.list.sel].path)) and
            not files.exists(string.format("%s/sce_sys/param.sfo",explorer.list[scroll.list.sel].path)) then return end

		local x,y = (960-420)/2,(544-420)/2
        local resp=0

		local tmp_vpk  = {}

        local info = game.info(string.format("%s/sce_sys/param.sfo",explorer.list[scroll.list.sel].path))
        tmp_vpk.img = image.load(string.format("%s/sce_sys/icon0.png",explorer.list[scroll.list.sel].path))
 
        local res,xscr = false,290
        local Xa = "O: "
        local Oa = "X: "
        if accept_x == 1 then Xa,Oa = "X: ","O: " end
        while true do
            buttons.read()
			if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
 
            draw.fillrect(x,y,420,420, color.new(0x2f,0x2f,0x2f,0xff))
            draw.framerect(x,y,420,420, color.black, color.shine,6)
   
            if info then
                if screen.textwidth(tostring(info.TITLE) or "UNK") > 380 then
                    xscr = screen.print(xscr, y+12, tostring(info.TITLE) or "UNK",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__SLEFT,380)
                else
                    screen.print(960/2,y+12,tostring(info.TITLE),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
                end
                if info.CATEGORY == "gp" then
                    screen.print(960/2,y+35,"UPDATE: "..tostring(info.APP_VER) or "",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
                else
                    screen.print(960/2,y+35,tostring(info.APP_VER) or "",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
                end
                screen.print(960/2,y+55,tostring(info.TITLE_ID),1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            end
			if tmp_vpk.img then
				tmp_vpk.img:scale(150)
				tmp_vpk.img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
				tmp_vpk.img:center()
				tmp_vpk.img:blit(960/2,544/2)
            end
 
            screen.print(960/2,y+325,STRINGS_SUBMENU_INSTALL_GAME +" ?",1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            screen.print(960/2,y+395,Xa..STRINGS_CONFIRM.." | "..Oa..STRINGS_SUBMENU_CANCEL,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ACENTER)
            screen.flip()
 
            if buttons[accept] or buttons[cancel] then
                if buttons[accept] then res = true end
                break
            end
        end

        if res == false then
			os.delay(15)
			if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
			return
		end
 
        buttons.homepopup(0)
        reboot=false
            local result = game.installdir(explorer.list[scroll.list.sel].path)
        buttons.homepopup(1)
        reboot=true
 
		bufftmp = nil
		if result ==1 then

			--Restore Save from "ux0:data/ONEMenu/Saves
			if files.exists("ux0:data/ONEMenu/SAVES/"..info.TITLE_ID) then
				local info_time = files.info("ux0:data/ONEMenu/SAVES/"..info.TITLE_ID)
				if os.message(STRINGS_APP_RESTORE_SAVE.."\n\n"..info_time.mtime or "", 1) == 1 then
					files.copy("ux0:data/ONEMenu/SAVES/"..info.TITLE_ID, "ux0:user/00/savedata/")
				end
			end

			if os.message(STRINGS_LAUNCH_GAME+"\n\n"+info.TITLE_ID+" ?",1) == 1 then
				if game.exists(info.TITLE_ID) then
					if info.CATEGORY == "ME" then game.open(info.TITLE_ID) else game.launch(info.TITLE_ID) end
				end
			end

			fillappmanlist(tmp_vpk, info)
			appman.len +=1
			infodevices()

		else
			os.message(STRINGS_INSTALL_ERROR)
		end

--clean
        menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
        multi={}
    end
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

local installtheme_callback = function ()
    if #explorer.list > 0 then
 
        if not files.exists(string.format("%s/theme.xml",explorer.list[scroll.list.sel].path)) then return end
       
        local path_tmp = explorer.list[scroll.list.sel].path
 
        if Root2[Dev] != "ux0:" then --return end
            if files.copy(explorer.list[scroll.list.sel].path,"ux0:data/customtheme")==1 then files.delete(explorer.list[scroll.list.sel].path) end
            path_tmp = "ux0:data/customtheme/"..explorer.list[scroll.list.sel].name
        end
 
        buttons.homepopup(0)
            reboot=false
                local result = themes.install(path_tmp)
            buttons.homepopup(1)
        reboot=true
 
        os.message(STRINGS_SUBMENU_INSTALLCTHEME.."\n\n"..STRINGS_RESULT..result)
        if result == 1 then
            if os.message(STRINGS_THEMES_SETTINGS,1)==1 then
                os.delay(150)
                os.uri("settings_dlg:custom_themes")
            end
        end
 
--clean
        menu_ctx.wakefunct()
        menu_ctx.close = true
        action = false
        explorer.refresh(true)
        explorer.action = 0
        multi={}
    end
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

local filesexport_callback = function ()

	local _path = explorer.list[scroll.list.sel].path
	local no_paths = {
		"ux0:app", "ux0:/app", "ux0:patch", "ux0:/patch",
		"ur0:app", "ur0:/app", "ur0:patch", "ur0:/patch",
		"uma0:app", "uma0:/app", "uma0:patch", "uma0:/patch",
	}

	for i=1,#no_paths do
		local x1,x2 = string.find(_path:lower(), no_paths[i], 1, true)
		if x1 then return false	end
	end

	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	local pos_menu = menu_ctx.scroll.sel

    local result = 0
	if #explorer.list > 0 then
		if not explorer.list[scroll.list.sel].size then                -- Its Dir

			local cont_multimedia,cont_img,cont_mp3,cont_mp4 = 0,0,0,0

			if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
			message_wait()

			local tmp = files.listfiles(explorer.list[scroll.list.sel].path)
			if tmp and #tmp > 0 then

				for i=1,#tmp do
					local ext = tmp[i].ext:lower() or ""
					if ext == "png" or ext == "jpg" or ext == "bmp" or ext == "gif" or ext == "mp3" or ext == "mp4" then
						cont_multimedia+=1
						reboot=false
							if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
							message_wait(tmp[i].name)
							local res = files.export(tmp[i].path)
						reboot=true

						if res == 1 then
							result = 1
							if ext == "png" or ext == "jpg" or ext == "bmp" or ext == "gif" then cont_img+=1
								elseif ext == "mp3" then cont_mp3+=1
									else cont_mp4+=1 end
						else
							os.message(STRINGS_EXPORT_FAIL.."\n\n"..tmp[i].name,0)
						end
					end
				end--for

			end

			if cont_multimedia > 0 then
				os.message(STRINGS_EXPORT_MP3..cont_mp3.."\n\n"..STRINGS_EXPORT_MP4..cont_mp4.."\n\n"..STRINGS_EXPORT_IMG..cont_img.."\n\n"..STRINGS_EXPORT_OPEN)
			else
				os.message(STRINGS_EXPORT_NO_FILES)
			end

		else
			local ext = explorer.list[scroll.list.sel].ext:lower() or ""
			if ext == "png" or ext == "jpg" or ext == "bmp" or ext == "gif" or ext == "mp3" or ext == "mp4" then
				reboot=false
					if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
					message_wait()
					result = files.export(explorer.list[scroll.list.sel].path)
				reboot=true

				if result == 1 then
					if os.message(STRINGS_EXPORT_OPEN_APP,1)==1 then
						os.delay(150)
						if ext == "mp3" then os.uri("music:browse?category=ALL")
						elseif ext == "mp4" then os.uri("video:browse?category=ALL")
						else os.uri("photo:browse?category=ALL") end
					end
				else
					os.message(STRINGS_EXPORT_FAIL.."\n\n"..explorer.list[scroll.list.sel].name,0)
				end
			end
		end
	end

	if result == 1 then
--clean
		menu_ctx.wakefunct()
		menu_ctx.close = true
		action = false
		explorer.refresh(true)
		multi={}
		explorer.action = 0
    end

	menu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

url = nil

--Parse MF
parseMF_callback = function ()

	http.getfile(url, "ux0:downloads/tmp")

	local data = {}
    for line in io.lines("ux0:downloads/tmp") do
		if line:find('gbtnSecondary" href=') then
			local en=line:find('gbtnSecondary" href=')  --Guardo dónde termina ese patrón
			local en2,urlf
			en=line:find("'",en) --ara busco la comilla sencilla, empezando por donde terminaba el patron anterior
			en2=line:find("'",en+1) -- busco la siguiente comilla

			urlf=line:sub( en+1, en2-1) --y recorto la URL

			data.url = urlf
			data.name = files.nopath(urlf)
		end

		if line:find("<span class='dlFileSize'>") then
			data.size = line:match("%<span class='dlFileSize'%>%((.+)%)%</span%>")
		end

	end
	return data

end

--Parse Zippyshare
parseZY_callback = function ()

	http.getfile(url, "ux0:downloads/tmp")
	local data,nflag={},false
	for line in io.lines("ux0:downloads/tmp") do

		if line:find("getElementById%('dlbutton'%)") then
			line=line:match("href = (.+);")
			p1=line:match('(/.+/)"')
				nb=line:match(" %((.+)%) ")
					assert(loadstring('nb='..nb))()
				p2=line:match(' "(/.+4)"')
			data.url=p1..nb..p2
		end

		if nflag then
			data.name = line:match('"%>(.+)%</')
			nflag=false
		end

		if line:find('"%>Name:%</') then
			nflag=true
		end

		if line:find('"%>Size:%</') then
			data.size = line:match('px;"%>(.+)%</')
		end

	end

	data.url=url:match("http.+%.com")..data.url

	return data

end

--Parse GDrive
parseGD_callback = function ()

	local data, ID = {url="https://drive.google.com/uc?export=download&id="}, ""

	if url:find("?id=") then
		ID=url:match("?id=(.+)")
	elseif url:find("file/d/") then
		ID=url:match("file/d/(.+)/.+")
	else return nil end
	data.url=data.url..ID

	http.getfile(url, "ux0:downloads/tmp")
	local file=io.open("ux0:downloads/tmp")
	if file then
		local line=file:read()
		data.name=line:match("title%>(.+) %- Google Drive%</")
			
		file:close()
	end

	return data

end

__NAME_DOWNLOAD = ""
local qr_callback = function ()

	__NAME_DOWNLOAD = ""
	files.delete("ux0:downloads/tmp")
	if not wlan.isconnected() then wlan.connect() end

	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end

	local pos_menu = menu_ctx.scroll.sel
	menu_ctx.wakefunct()

	url = cam.scanqr(STRINGS_SUBMENU_QR_SCAN,theme.style.TXTBKGCOLOR)

	local servers = {
		{ name = "mediafire", 		funct = parseMF_callback },
		{ name = "zippyshare",		funct = parseZY_callback },
		{ name = "drive.google",	funct = parseGD_callback },
	}

	local parse,url_backup,pflag = {},"",false
	if url then

		url_backup = url

		for i=1,#servers do
			if string.find(url:lower(), servers[i].name, 1, true) then
				parse = servers[i].funct()
				pflag = true
				break
			end
		end

		local res,filename = "",false
		if parse and pflag then
			if wlan.isconnected() then

				__NAME_DOWNLOAD = parse.name or ""
				buttons.homepopup(0)
					res,filename = http.getfile(parse.url,"ux0:downloads/"..parse.name or "")
				buttons.homepopup(1)

				if parse.name then filename = parse.name end

				if res then
					if files.exists("ux0:downloads/"..filename) then
						os.message(STRINGS_DOWNLOAD_SUCCESS.." ux0:downloads\n\n"..filename)
						explorer.refresh(true)
					end
				else
					files.delete("ux0:downloads/"..filename)
					os.message(STRINGS_DOWNLOAD_FAILED.." ux0:downloads\n\n"..filename)
				end
			end
		else

			res,filename = http.getfile(url_backup,"ux0:downloads/")

			if not res then
				filename = osk.init(STRINGS_SUBMENU_QR_DOWNLOAD, STRINGS_SUBMENU_QR_FILENAME, 256, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
				if filename then tmp = filename else tmp = "file" end
				__NAME_DOWNLOAD = tmp or ""
				http.download(url_backup,"ux0:downloads/"..filename)
			end
			if filename then tmp = filename else tmp = "file" end

			if files.exists("ux0:downloads/"..tmp) then
				os.message(STRINGS_DOWNLOAD_SUCCESS.." ux0:downloads\n\n"..tmp)
				explorer.refresh(true)
			else
				files.delete("ux0:downloads/"..tmp)
				os.message(STRINGS_DOWNLOAD_FAILED.." ux0:downloads\n\n"..tmp)
			end
		end
	end
	files.delete("ux0:downloads/tmp")

--clean
	__NAME_DOWNLOAD = ""
	action = false
	explorer.action = 0
	multi={}
	menu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	os.delay(50)
end

local cancel_callback = function ()
	menu_ctx.wait_action = __ACTION_WAIT_NOTHING
	menu_ctx.wakefunct()
--clean
	menu_ctx.close = true
	action = false
	explorer.refresh(false)
	explorer.action = 0
	multi={}
end

---------------------------------- SubMenu Contextual 2 ---------------------------------------------------
local usb_callback = function ()
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	local pos_menu = menu_ctx.scroll.sel
	usbMassStorage()
	buttons.read()
	menu_ctx.wakefunct2()
	menu_ctx.scroll.sel = pos_menu

	os.delay(150)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

local ftp_callback = function ()
	local vbuff = screen.toimage()
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
	buttons.homepopup(0)
    local pos_menu = menu_ctx.scroll.sel
    if startftp() then
--clean
		action = false
		explorer.refresh(true)
		multi={}
		explorer.action = 0
    end
	buttons.homepopup(1)
	menu_ctx.wakefunct2()
    menu_ctx.scroll.sel = pos_menu
	os.delay(15)
	if vbuff then vbuff:blit(0,0) elseif theme.data["list"] then theme.data["list"]:blit(0,0) end
end

local refresh_callback = function ()
	local pos_menu = menu_ctx.scroll.sel
	refresh_init(theme.data["list"])
	menu_ctx.wakefunct2()
	menu_ctx.scroll.sel = pos_menu
end

local updatedb_callback = function ()
	os.delay(150)
	_print=false
	os.updatedb()
	os.message(STRINGS_RESTART_UPDATEDB)
	os.delay(1500)
	power.restart()
end

local rebuilddb_callback = function ()
	os.delay(150)
	_print=false
	os.rebuilddb()
	os.message(STRINGS_RESTART_REBUILDDB)
	os.delay(1500)
	power.restart()
end

local reloadconfig_callback = function ()
	local pos_menu = menu_ctx.scroll.sel
	os.taicfgreload()
	os.message(STRINGS_CONFIG_SUCCESS)
	menu_ctx.scroll.sel = pos_menu
end

local scanfavs_callback = function ()
	local pos_menu = menu_ctx.scroll.sel
	favorites_manager()
	menu_ctx.wakefunct2()
	menu_ctx.scroll.sel = pos_menu
end

local themesLiveArea_callback = function ()
	local pos_menu = menu_ctx.scroll.sel
	customthemes()
	menu_ctx.wakefunct2()
	menu_ctx.scroll.sel = pos_menu
end

local font_callback = function ()
	local pos_menu = menu_ctx.scroll.sel
	if not __USERFNT then
		if __FNT == 2 then __FNT = 3 else __FNT = 2 end 
		write_config()
		os.delay(150)
		font.setdefault(__FNT)
		menu_ctx.wakefunct2()
	end
	menu_ctx.scroll.sel = pos_menu
end

local restart_callback = function ()
    os.delay(150)
    os.restart()
end

local reboot_callback = function ()
    os.delay(1000)
    power.restart()
end

local shutdown_callback = function ()
    os.delay(1000)
    power.shutdown()
end

menu_ctx = { -- Creamos un objeto menu contextual
    h = 544,				-- Height of menu
    w = 190,				-- Width of menu--170
    x = -190,				-- X origin of menu--160
    y = 0,					-- Y origin of menu
    open = false,			-- Is open the menu?
    close = true,
    speed = 10,				-- Speed of Effect Open/Close.
    ctrl = "triangle",		-- The button handle Open/Close menu.
    scroll = newScroll(),	-- Scroll of menu options.
	wait_action = 0,
}

function menu_ctx.wakefunct()
    menu_ctx.options = { 	-- Handle Option Text and Option Function
		{ text = STRINGS_SUBMENU_DELETE,        funct = delete_callback },
		{ text = STRINGS_SUBMENU_RENAME,        funct = rename_callback },
		{ text = STRINGS_SUBMENU_SIZE,          funct = sizedir_callback },

		{ text = STRINGS_NEW_FILE,       		funct = newfile_callback },
		{ text = STRINGS_SUBMENU_MAKEDIR,       funct = makedir_callback },

		{ text = STRINGS_SUBMENU_INSTALL_GAME, 	funct = installgame_callback },
		{ text = STRINGS_SUBMENU_INSTALLCTHEME,	funct = installtheme_callback },
        { text = STRINGS_SUBMENU_EXPORT,        funct = filesexport_callback },
		{ text = STRINGS_SUBMENU_QR,            funct = qr_callback },

		{ text = STRINGS_SUBMENU_CANCEL,        funct = cancel_callback },

    }
    if menu_ctx.wait_action==__ACTION_WAIT_PASTE then
        table.insert(menu_ctx.options, 1, { text = STRINGS_SUBMENU_PASTE,       funct = paste_callback })
    elseif menu_ctx.wait_action==__ACTION_WAIT_EXTRACT then
        table.insert(menu_ctx.options, 1, { text = STRINGS_SUBMENU_EXTRACT_TO,  funct = paste_callback })
    else
        table.insert(menu_ctx.options, 1, { text = STRINGS_SUBMENU_COPY,        funct =  src_path_callback })
        table.insert(menu_ctx.options, 2, { text = STRINGS_SUBMENU_MOVE,        funct = src_path_callback })
        table.insert(menu_ctx.options, 3, { text = STRINGS_SUBMENU_EXTRACT,     funct = src_path_callback })
    end
    menu_ctx.scroll = newScroll(menu_ctx.options, #menu_ctx.options)
end

function menu_ctx.wakefunct2()
    menu_ctx.options = { -- Handle Option Text and Option Function
        { text = STRINGS_USB,           		funct = usb_callback },
		{ text = STRINGS_SUBMENU_FTP,       	funct = ftp_callback },
		{ text = STRINGS_REFRESH_LIVEAREA,  	funct = refresh_callback },

		{ text = STRINGS_SUBMENU_RESTART,   	funct = restart_callback },
        { text = STRINGS_SUBMENU_RESET,     	funct = reboot_callback },
        { text = STRINGS_SUBMENU_POWEROFF,  	funct = shutdown_callback },

		{ text = STRINGS_UPDATE_DB, 			funct = updatedb_callback },
		{ text = STRINGS_REBUILD_DB, 			funct = rebuilddb_callback },
		{ text = STRINGS_RELOAD_CONFIG,			funct = reloadconfig_callback },

		{ text = STRINGS_FAVORITES_SECTION,		funct = scanfavs_callback },
		{ text = STRINGS_SUBMENU_CUSTOMTHEMES,	funct = themesLiveArea_callback },
    }
	if __FNT == 3 then 
		table.insert(menu_ctx.options, { text = "< "..STRINGS_PVF_FONT.." >", funct = font_callback, pad = true })
	else
		table.insert(menu_ctx.options, { text = "< "..STRINGS_PGF_FONT.." >", funct = font_callback, pad = true })
	end

    menu_ctx.scroll = newScroll(menu_ctx.options, #menu_ctx.options)
end

menu_ctx.wakefunct()
menu_ctx.wakefunct2()

function menu_ctx.run()

    if buttons[menu_ctx.ctrl] then menu_ctx.close = not menu_ctx.close end
	if buttons[menu_ctx.ctrl] then
		menu_ctx.type = 1
		menu_ctx.wakefunct()
	end

    menu_ctx.draw()
	menu_ctx.buttons()
end

local x_print = 5
function menu_ctx.draw()

    if not menu_ctx.close and menu_ctx.x < 0 then
        menu_ctx.x += menu_ctx.speed
    elseif menu_ctx.close and menu_ctx.x > -menu_ctx.w then
        menu_ctx.x -= menu_ctx.speed
    end

	if menu_ctx.x > -menu_ctx.w then
		draw.fillrect(menu_ctx.x, menu_ctx.y, menu_ctx.w, menu_ctx.h, theme.style.BARCOLOR)
	end

    if menu_ctx.x >= 0 then

        menu_ctx.open = true
        local h = menu_ctx.y + 75 -- Punto de origen de las opciones
        for i=menu_ctx.scroll.ini,menu_ctx.scroll.lim do

			screen.clip(0,0,menu_ctx.w-5, menu_ctx.h)
			if i==menu_ctx.scroll.sel then

				draw.fillrect(0,h-4,menu_ctx.w,25,theme.style.SELCOLOR)

				if screen.textwidth(menu_ctx.options[i].text) > menu_ctx.w-10 then
					x_print = screen.print(x_print, h, menu_ctx.options[i].text, 1, color.green, color.blue, __SLEFT,menu_ctx.w-10)
				else
					screen.print(5, h, menu_ctx.options[i].text, 1, color.green, color.blue, __ALEFT)
					x_print = 5
				end

			else
				screen.print(5, h, menu_ctx.options[i].text, 1, theme.style.TXTCOLOR, color.blue, __ALEFT)
			end
			screen.clip()

			if menu_ctx.type == 1 and (i == 3 or i == 6 or i == 8 or i == 11) then
				h += 35
			elseif menu_ctx.type == 2 and (i == 3 or i == 6 or i == 9) then
				h += 35
			else
				h += 26
			end
        end
    else
        menu_ctx.open = false
    end
end

function menu_ctx.buttons()
	if not menu_ctx.open then return end

	if buttons.up or buttons.analogly < -60 then menu_ctx.scroll:up() end
	if buttons.down or buttons.analogly > 60 then menu_ctx.scroll:down() end

	if buttons[cancel] then -- Run function of cancel option.
		menu_ctx.close = not menu_ctx.close
	end

	if buttons[accept] then
		menu_ctx.options[menu_ctx.scroll.sel].funct()
    end
	if (buttons.left or buttons.right) and menu_ctx.options[menu_ctx.scroll.sel].pad then
		menu_ctx.options[menu_ctx.scroll.sel].funct()
	end

	if buttons.released.l or buttons.released.r then
		if menu_ctx.type == 1 then
			menu_ctx.type = 2
			menu_ctx.wakefunct2()
		else
			menu_ctx.type = 1
			menu_ctx.wakefunct()
		end
	end

end
