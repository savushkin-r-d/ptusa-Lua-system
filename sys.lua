local G = _G

module( 'sys' )
-- ----------------------------------------------------------------------------
--Класс технологический объект со значениями параметров по умолчанию.
project_tech_object =
    {
    name         = "TANK",
    number       = 1,
    modes_count = 32,

    timers_count               = 1,
    params_float_count         = 1,
    runtime_params_float_count = 1,
    params_uint_count          = 1,
    runtime_params_uint_count  = 1,

    sys_tech_object = 0,
    }
-- ----------------------------------------------------------------------------
--Создание экземпляра класса, при этом создаем соответствующий системный
--технологический объект из С++.
function project_tech_object:new( o )

    o = o or {} -- Create table if user does not provide one.
    G.setmetatable( o, self )
    self.__index = self

   --Создаем системный объект.
    o.sys_tech_object = G.tech_object( o.name, o.number, o.modes_count,
        o.timers_count, o.params_float_count,
        o.runtime_params_float_count, o.params_uint_count,
        o.runtime_params_uint_count )

    --Переназначаем переменную для параметров, для удобного доступа.
    o.rt_par_float = o.sys_tech_object.rt_par_float
    o.par_float = o.sys_tech_object.par_float
    o.timers = o.sys_tech_object.timers

    return o
end
-- ----------------------------------------------------------------------------
--Заглушки для функций, они ничего не делают, вызываются если не реализованы
--далее в проекте (файл main.lua).
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
--Функции, которые переадресуются в вызовы соответствующих функций
--системного технологического объекта (релизованы на С++).
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
-- ----------------------------------------------------------------------------
--Представление всех созданных пользовательских технологических объектов.
object_manager =
    {
    objects = {}, --Пользовательские технологические объекты.

    --Добавление пользовательского технологического объекта.
    add_object = function ( self, new_object )
        self.objects[ #self.objects + 1 ] = new_object

        G.sys[ new_object.name ] = G.sys[ new_object.name ] or { }
        G.sys[ new_object.name ][ new_object.number ] = new_object
    end,

    --Получение количества пользовательских технологических объектов.
    get_objects_count = function( self )
        return #self.objects
    end,

    --Получение пользовательского технологического объекта.
    get_object = function( self, object_idx )
        local res = self.objects[ object_idx ]
        if res then
            return self.objects[ object_idx ].sys_tech_object
        else
            return 0
        end
    end
    }

G.object_manager = object_manager
-- ----------------------------------------------------------------------------
--Функции, которые для выполнения команды от сервера преобразуют тег в объект.
--Пример команды от сервера в виде скрипта:
--  cmd = sys.V[95]:set_cmd( "st", 0, 1 )
--  cmd = sys.TANK[13]:set_cmd( "CMD", 0, 1000 )

local function create_device( name )
    G.sys[ name ] = { }
    local t = G.sys[ name ]

    -- Переопределяем операцию индексирования.
    function t.__index( op, key )
        return G.G_DEVICE_MANAGER():get_device( G.device[ 'DT_'..name ], key )
    end

    G.setmetatable( t, t )
end

create_device( 'V' )
create_device( 'N' )
create_device( 'M' )
create_device( 'LS' )
create_device( 'TE' )
create_device( 'FE' )
create_device( 'FS' )
create_device( 'CTR' )
create_device( 'AO' )
create_device( 'LE' )
create_device( 'FB' )
create_device( 'UPR' )
create_device( 'QE' )
create_device( 'AI' )
-- ----------------------------------------------------------------------------
SYSTEM = G.G_PAC_INFO() --Информаци о PAC
-- ----------------------------------------------------------------------------
