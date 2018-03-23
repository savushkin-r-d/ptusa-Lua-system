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
						end
					else
						gate.step = 1
					end
				elseif gate.step == 1 then
					if gate.docnt + gate.aocnt > 0 then
						if gate.mclient:async_write_multiply_registers(0,gate.docnt + 2 * gate.aocnt) == 1 then
							for mb_reg = 0, gate.docnt - 1, 1 do
								gate.mclient:set_int2(mb_reg, gate.DO[mb_reg + 1]:get_state())
							end
							for mb_reg2 = 0, gate.aocnt - 1, 1 do
								gate.mclient:set_float(gate.docnt + mb_reg2 * 2, gate.AO[mb_reg2 + 1]:get_value())
							end
							gate.step = 2
							gate.timer = get_millisec()
						end
					else
						gate.step = 2
						gate.timer = get_millisec()
					end
				elseif gate.step == 2 then
					if get_delta_millisec(gate.timer) > gate.cycletime then
						gate.step = 0
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
            elseif coil_n >= dicnt and coil_n < dicnt + aicnt then
                res[#res - 1] = 2
                res[#res] = SDAI[coil_n + 1]:get_value()  
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
                SDDO[coil_n + 1]:set_state(ModbusServ:UnpackInt16(buff, coil_n * 2))
            elseif coil_n >= docnt and coil_n < docnt + aocnt then
                SDAO[coil_n + 1]:set_value(ModbusServ:UnpackFloat(buff, coil_n * 2))  
            end
        end
    end

end