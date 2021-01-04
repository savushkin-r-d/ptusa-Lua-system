require('shared')
print('Check shared devices')
if shared_devices ~= nil then
	for gateindex, gate in pairs(shared_devices) do
		print('Check shared_devices['..gateindex..']')
	    if gate.DO ~= nil then
	       	for idx = 1, #gate.DO, 1 do
				if gate.DO[idx] == nil then
					print('ERROR - DO['..idx..'] is null')
					gate.DO[idx]:get_state() --trigger error
				end
			end
	    end
	    if gate.DI ~= nil then
	       	for idx = 1, #gate.DI, 1 do
				if gate.DI[idx] == nil then
					print('ERROR - DI['..idx..'] is null')
					gate.DI[idx]:get_state() --trigger error
				end
			end
	    end
	    if gate.AI ~= nil then
	       	for idx = 1, #gate.AI, 1 do
				if gate.AI[idx] == nil then
					print('ERROR - AI['..idx..'] is null')
					gate.AI[idx]:get_value() --trigger error
				end
			end
	    end
	    if gate.AO ~= nil then
	       	for idx = 1, #gate.AO, 1 do
				if gate.AO[idx] == nil then
					print('ERROR - AO['..idx..'] is null')
					gate.AO[idx]:get_value() --trigger error
				end
			end
	    end
	end
end
if remote_gateways ~= nil then
	for gateindex, gate in pairs(remote_gateways) do
		print('Check remote_gateways['..gateindex..']')
	    if gate.DO ~= nil then
	       	for idx = 1, #gate.DO, 1 do
				if gate.DO[idx] == nil then
					print('ERROR - DO['..idx..'] is null')
					gate.DO[idx]:get_state() --trigger error
				end
			end
	    end
	    if gate.DI ~= nil then
	       	for idx = 1, #gate.DI, 1 do
				if gate.DI[idx] == nil then
					print('ERROR - DI['..idx..'] is null')
					gate.DI[idx]:get_state() --trigger error
				end
			end
	    end
	    if gate.AI ~= nil then
	       	for idx = 1, #gate.AI, 1 do
				if gate.AI[idx] == nil then
					print('ERROR - AI['..idx..'] is null')
					gate.AI[idx]:get_value() --trigger error
				end
			end
	    end
	    if gate.AO ~= nil then
	       	for idx = 1, #gate.AO, 1 do
				if gate.AO[idx] == nil then
					print('ERROR - AO['..idx..'] is null')
					gate.AO[idx]:get_value() --trigger error
				end
			end
	    end
	end
end

function init_gateways( mgates )
	local i = 1
	for gatename, gate in pairs(mgates) do
		if gate.enabled then
			if G_PAC_INFO():is_emulator() == false then
				gate.mclient = modbus_client( i, gate.ip, gate.port, gate.timeout )
			else
				local ipl = '127.0.0.1'
				if gate.ipemulator ~= nil then
					ipl = gate.ipemulator
				end
				gate.mclient = modbus_client( i, ipl, gate.port, gate.timeout )
			end
			gate.mclient:set_station( gate.station )
			gate.step = 0
			gate.timer = get_millisec()
			gate.dicnt = 0
			gate.docnt = 0
			gate.aicnt = 0
			gate.aocnt = 0
			gate.error = false
			gate.lastsuccessquery = get_millisec()
			if gate.DO ~= nil then
				gate.docnt = #gate.DO
			end
			if gate.DI ~= nil then
				gate.dicnt = #gate.DI
			end
			if gate.AO ~= nil then
				gate.aocnt = #gate.AO
			end
			if gate.AI ~= nil then
				gate.aicnt = #gate.AI
			end
			i = i + 1
		end
	end
end

function  eval_gateways( mgates )
	local  mb_reg, mb_reg2, mb_new_state
	for gatename, gate in pairs(mgates) do
		if gate.enabled then
			if G_PAC_INFO():is_emulator() == false or gate.emulation then
				if gate.step == 0 then
					if gate.dicnt + gate.aicnt > 0 then
						if  gate.mclient:async_read_holding_registers(0, gate.dicnt + 2 * gate.aicnt) == 1 then
							for mb_reg = 0, gate.dicnt - 1, 1 do
								mb_new_state = gate.mclient:get_int2(mb_reg)
								if mb_new_state == 0 then
									gate.DI[mb_reg + 1]:off()
								else
									gate.DI[mb_reg + 1]:on()
								end
							end
							for mb_reg2 = 0, gate.aicnt - 1, 1 do
								gate.AI[mb_reg2 + 1]:set_value(gate.mclient:get_float(gate.dicnt + mb_reg2 *2))
							end
							gate.step = 1
							gate.error = false
							gate.lastsuccessquery = get_millisec()
						else
							if get_delta_millisec(gate.lastsuccessquery) > 7000 then
								gate.error = true
							end
						end
					else
						gate.step = 1
						gate.error = false
						gate.lastsuccessquery = get_millisec()
					end
				elseif gate.step == 1 then
					if gate.docnt + gate.aocnt > 0 then
						for mb_reg = 0, gate.docnt - 1, 1 do
							gate.mclient:set_int2(mb_reg, gate.DO[mb_reg + 1]:get_state())
						end
						for mb_reg2 = 0, gate.aocnt - 1, 1 do
							gate.mclient:set_float(gate.docnt + mb_reg2 * 2, gate.AO[mb_reg2 + 1]:get_value())
						end
						if gate.mclient:async_write_multiply_registers(0,gate.docnt + 2 * gate.aocnt) == 1 then
							gate.step = 2
							gate.error = false
							gate.lastsuccessquery = get_millisec()
							gate.timer = get_millisec()
						else
							if get_delta_millisec(gate.lastsuccessquery) > 7000 then
								gate.error = true
							end
						end
					else
						gate.step = 2
						gate.error = false
						gate.lastsuccessquery = get_millisec()
						gate.timer = get_millisec()
					end
				elseif gate.step == 2 then
					if get_delta_millisec(gate.timer) > gate.cycletime then
						gate.step = 0
						gate.error = false
						gate.lastsuccessquery = get_millisec()
					end
				end
			end
		end
	end
end

function read_hr( n, start_idx, count )
    local res = {}
    if shared_devices[n] ~= nil then
        local SDAI = shared_devices[n].AI
        local SDDI = shared_devices[n].DI
        local dicnt = 0
        local coil_n = 0
        if SDDI ~= nil then
            dicnt = #SDDI
        end
        local aicnt = 0
        if SDAI ~= nil then     
            aicnt = #SDAI
        end
        for coil_n = start_idx, start_idx + count, 1 do
            res[ #res + 1 ] = 0 --Добавляем новый элемент.
            res[ #res + 1 ] = 0
            if coil_n < dicnt then
                res[#res - 1] = 1
                res[#res] = SDDI[coil_n + 1]:get_state()
            elseif coil_n >= dicnt and coil_n < dicnt + aicnt * 2 then
            	if (coil_n - dicnt) % 2 == 0 then
                	res[#res - 1] = 2
                	res[#res] = SDAI[(coil_n - dicnt) / 2 + 1]:get_value()
                end  
            end
        end
    end

    return res
end

function write_hr( n, start_idx, count, buff )
    if shared_devices[n] ~= nil then
        local SDAO = shared_devices[n].AO
        local SDDO = shared_devices[n].DO
        local docnt = 0
        local coil_n = 0
        if SDDO ~= nil then
            docnt = #SDDO
        end
        local aocnt = 0
        if SDAO ~= nil then     
            aocnt = #SDAO
        end
        if docnt > 0 then
        	for coil_n = 0, docnt - 1, 1 do
        		SDDO[coil_n + 1]:set_state(ModbusServ:UnpackInt16(buff, coil_n * 2))
        	end
        end
        if aocnt > 0 then
        	for coil_n = 0, aocnt - 1, 1 do
        		SDAO[coil_n + 1]:set_value(ModbusServ:UnpackFloat(buff, docnt * 2 + coil_n * 4))
        	end
        end  
    end

end

--Для обмена между проектами парами DI-DO AI-AO
function read_hr2( n, start_idx, count )
    local res = {}
    if shared_devices[n] ~= nil then
        local SDAO = shared_devices[n].AO
        local SDDO = shared_devices[n].DO
        local docnt = 0
        local coil_n = 0
        if SDDO ~= nil then
            docnt = #SDDO
        end
        local aocnt = 0
        if SDAO ~= nil then     
            aocnt = #SDAO
        end
        for coil_n = start_idx, start_idx + count, 1 do
            res[ #res + 1 ] = 0 --Добавляем новый элемент.
            res[ #res + 1 ] = 0
            if coil_n < docnt then
                res[#res - 1] = 1
                res[#res] = SDDO[coil_n + 1]:get_state()
            elseif coil_n >= docnt and coil_n < docnt + aocnt * 2 then
            	if (coil_n - docnt) % 2 == 0 then
                	res[#res - 1] = 2
                	res[#res] = SDAO[(coil_n - docnt) / 2 + 1]:get_value()
                end  
            end
        end
    end

    return res
end

function write_hr2( n, start_idx, count, buff )
	local mb_new_state
    if shared_devices[n] ~= nil then
        local SDAI = shared_devices[n].AI
        local SDDI = shared_devices[n].DI
        local dicnt = 0
        local coil_n = 0
        if SDDI ~= nil then
            dicnt = #SDDI
        end
        local aicnt = 0
        if SDAI ~= nil then     
            aicnt = #SDAI
        end
        if dicnt > 0 then
        	for coil_n = 0, dicnt - 1, 1 do
        		mb_new_state = ModbusServ:UnpackInt16(buff, coil_n * 2)
        		if mb_new_state == 0 then
					SDDI[coil_n + 1]:off()
				else
					SDDI[coil_n + 1]:on()
				end
        	end
        end
        if aicnt > 0 then
        	for coil_n = 0, aicnt - 1, 1 do
        		SDAI[coil_n + 1]:set_value(ModbusServ:UnpackFloat(buff, dicnt * 2 + coil_n * 4))
        	end
        end  
    end

end
