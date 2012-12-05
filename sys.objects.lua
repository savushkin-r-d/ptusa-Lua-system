--version = 1

-- ----------------------------------------------------------------------------
--����� ��������������� ������ �� ���������� ���������� �� ���������.
project_tech_object =
    {
    name        = "������",
    n           = 1,
    modes_count = 32,

    timers_count               = 1,
    params_float_count         = 1,
    runtime_params_float_count = 1,
    params_uint_count          = 1,
    runtime_params_uint_count  = 1,

    sys_tech_object = 0,

    name_Lua = "OBJECT",

    idx = 1
    }
-- ----------------------------------------------------------------------------
--�������� ���������� ������, ��� ���� ������� ��������������� ���������
--��������������� ������ �� �++.
function project_tech_object:new( o )


    o = o or {} -- Create table if user does not provide one.
    setmetatable( o, self )
    self.__index = self

    --������� ��������� ������.
    o.sys_tech_object = tech_object( o.name,
        o.n,
        o.name_Lua..self.idx,
        o.modes_count,
        o.timers_count,
        o.params_float_count,
        o.runtime_params_float_count,
        o.params_uint_count,
        o.runtime_params_uint_count )

    --������������� ���������� ��� ����������, ��� �������� �������.
    o.rt_par_float = o.sys_tech_object.rt_par_float
    o.par_float = o.sys_tech_object.par_float
    o.timers = o.sys_tech_object.timers

    --����������� ����������� ��������.
    _G[ o.name_Lua..self.idx ] = o
    _G[ "_"..o.name_Lua..self.idx ] = o

    object_manager:add_object( o )

    self.idx = self.idx + 1
    return o
end
-- ----------------------------------------------------------------------------
--�������� ��� �������, ��� ������ �� ������, ���������� ���� �� �����������
--����� � ������� (���� main.lua).
function project_tech_object:exec_cmd( cmd )
    return 0
end

function project_tech_object:check_on_mode( mode )
    return 0
end

function project_tech_object:init_mode( mode )
    return 0
end

function project_tech_object:evaluate( par )
    return 0
end

function project_tech_object:check_off_mode( mode )
    return 0
end

function project_tech_object:final_mode( mode )
    return 0
end

function project_tech_object:init_params( par )
    return 0
end

function project_tech_object:init_runtime_params( par )
    return 0
end
-- ----------------------------------------------------------------------------
--�������, ������� �������������� � ������ ��������������� �������
--���������� ���������������� ������� (���������� �� �++).
function project_tech_object:get_modes_count()
    return self.sys_tech_object:get_modes_count()
end

function project_tech_object:get_mode( mode )
    return self.sys_tech_object:get_mode( mode )
end

function project_tech_object:set_mode( mode, new_state )
    return self.sys_tech_object:set_mode( mode, new_state )
end

function project_tech_object:exec_cmd( cmd )
    return self.sys_tech_object:exec_cmd( cmd )
end

function project_tech_object:get_modes_manager()
    return self.sys_tech_object:get_modes_manager()
end

function project_tech_object:set_cmd( prop, idx, n )
    return self.sys_tech_object:set_cmd( prop, idx, n )
end

function project_tech_object:set_param( par_id, index, value )
    return self.sys_tech_object:set_param( par_id, index, value )
end

function project_tech_object:set_err_msg( msg, mode, new_mode, msg_type )    
    new_mode = new_mode or 0
    msg_type = msg_type or tech_object.ERR_CANT_ON
    return self.sys_tech_object:set_err_msg( msg, mode, new_mode, msg_type )
end
-- ----------------------------------------------------------------------------
--������������� ���� ��������� ���������������� ��������������� ��������
--(��������, ������) ��� ������� �� C++.
object_manager =
    {
    objects = {}, --���������������� ��������������� �������.

    --���������� ����������������� ���������������� �������.
    add_object = function ( self, new_object )
        self.objects[ #self.objects + 1 ] = new_object
    end,

    --��������� ���������� ���������������� ��������������� ��������.
    get_objects_count = function( self )
        return #self.objects
    end,

    --��������� ����������������� ���������������� �������.
    get_object = function( self, object_idx )
        local res = self.objects[ object_idx ]
        if res then
            return self.objects[ object_idx ].sys_tech_object
        else
            return 0
        end
    end
    }
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
--������������� �������, ���������� � �.�. ��������.
OBJECTS = {}

init_tech_objects = function()

    process_dev = function( mode, step_n, action, devices )
        if devices ~= nil then

            for field, value in pairs( devices ) do
                assert( loadstring( "dev = _"..value ) )( )
                if dev == nil then
                    error( "Unknown device '"..value.."'." )
                end

                mode[ step_n ][ action ]:add_dev( dev, 0 )
            end
        end
    end

    process_seat = function( mode, step_n, action, devices, t )

        if devices ~= nil then

            local group = 0
            for field, value in pairs( devices ) do
                for field, value in pairs( value ) do
                    assert( loadstring( "dev = _"..value ) )( )
                    if dev == nil then
                        error( "Unknown device '"..value.."'." )
                    end

                    mode[ step_n ][ action ]:add_dev( dev, group, t )
                end
                group = group + 1
            end
        end
    end

    --������ ������� �� ������� � ���� �������:
    --  cmd = V95:set_cmd( "st", 0, 1 )
    --  cmd = OBJECT1:set_cmd( "CMD", 0, 1000 )
    SYSTEM = G_PAC_INFO() --��������� � PAC, ������� ��������� � Lua.

    for fields, value in ipairs( init_tech_objects_modes() ) do

        local modes_count = 0
        if ( value.modes ~= nil ) then
            modes_count = #value.modes
        end

        --������� ��������������� ������.
        local object = project_tech_object:new
            {
            name 	     = value.name,
            n 	         = value.n,
            modes_count  = modes_count,
            timers_count = value.timers,

            params_float_count 		   = value.par_float,
            runtime_params_float_count = value.rt_par_float,
            params_uint_count          = value.par_uint,
            runtime_params_uint_count  = value.rt_par_uint
            }

        local modes_manager = object:get_modes_manager()

        for fields, value in ipairs( value.modes ) do

            local mode = modes_manager:add_mode( value.name )

            process_dev(  mode, -1, step.A_ON,  value.opened_devices )
            process_dev(  mode, -1, step.A_OFF, value.closed_devices )

            process_seat( mode, -1, step.A_UPPER_SEATS_ON,
                value.opened_upper_seat_v, i_mix_proof.ST_UPPER_SEAT )
            process_seat( mode, -1, step.A_LOWER_SEATS_ON,
                value.opened_upper_seat_v, i_mix_proof.ST_LOWER_SEAT )

            process_dev(  mode, -1, step.A_REQUIRED_FB, value.required_FB )

            --������ ��������� DI->DO.
            if value.pair_DI_DO ~= nil then

                local group = 0
                for field, value in pairs( value.pair_DI_DO ) do
                    for field, value in pairs( value ) do
                        assert( loadstring( "dev = _"..value ) )( )
                        if dev == nil then
                            error( "Unknown device '"..value.."'." )
                        end
                        mode[ -1 ][ step.A_PAIR_DO_DI ]:add_dev( dev, group )
                    end

                    group = group + 1
                end
            end

            --����.
            if value.steps ~= nil then
                local steps_count = #value.steps

                for fields, value in ipairs( value.steps ) do
                    mode:add_step( value.name, 0, 0 )

                    local step_n = fields

                    process_dev(  mode, step_n, step.A_ON,  value.opened_devices )
                    process_dev(  mode, step_n, step.A_OFF, value.closed_devices )

                    process_seat( mode, step_n, step.A_UPPER_SEATS_ON,
                        value.opened_upper_seat_v, i_mix_proof.ST_UPPER_SEAT )
                    process_seat( mode, step_n, step.A_LOWER_SEATS_ON,
                        value.opened_upper_seat_v, i_mix_proof.ST_LOWER_SEAT )
                end
            end

--[[			--������ ���������, ����������� �� �� � ������� �������.
            if value.wash_data ~= nil then
                --FB
                local di_dev = value.wash_data.DI

                local n = modes_manager:add_mode_wash_action( mode,
                    di_dev )

                --Control signal
                local control_signal_dev_ex = G_DEVICE_MANAGER():get_device(
                        control_signal_dev_type, value.group_dev_ex.UPR )



                if value.group_dev_ex.dev ~= nil then

                    for field, value in pairs( value.group_dev_ex.dev ) do
                        local group    = value
                        local dev_type = get_dev_type( field )

                        for field, value in pairs( group ) do
                            local dev = G_DEVICE_MANAGER():get_device(
                                dev_type, value )
                            modes_manager:add_mode_FB_group_dev_ex( mode, n,
                                dev )
                        end
                    end
                end -- if value.dev ~= nil then
            end -- if value.group_dev_ex ~= nil then]]

        end --for fields, value in ipairs( value.modes ) do
    end --for fields, value in ipairs( tech_objects ) do

    return 0
end
