---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the SensorAppOverview_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_SensorAppOverview'

-- Timer to update UI via events after page was loaded
local tmrSensorAppOverview = Timer.create()
tmrSensorAppOverview:setExpirationTime(300)
tmrSensorAppOverview:setPeriodic(false)

-- Reference to global handle
local sensorAppOverview_Model

-- ************************ UI Events Start ********************************

-- Script.serveEvent("CSK_SensorAppOverview.OnNewEvent", "SensorAppOverview_OnNewEvent")
Script.serveEvent("CSK_SensorAppOverview.OnNewStatusLoadParameterOnReboot", "SensorAppOverview_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_SensorAppOverview.OnPersistentDataModuleAvailable", "SensorAppOverview_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_SensorAppOverview.OnNewParameterName", "SensorAppOverview_OnNewParameterName")
Script.serveEvent("CSK_SensorAppOverview.OnDataLoadedOnReboot", "SensorAppOverview_OnDataLoadedOnReboot")

Script.serveEvent('CSK_SensorAppOverview.OnUserLevelOperatorActive', 'SensorAppOverview_OnUserLevelOperatorActive')
Script.serveEvent('CSK_SensorAppOverview.OnUserLevelMaintenanceActive', 'SensorAppOverview_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_SensorAppOverview.OnUserLevelServiceActive', 'SensorAppOverview_OnUserLevelServiceActive')
Script.serveEvent('CSK_SensorAppOverview.OnUserLevelAdminActive', 'SensorAppOverview_OnUserLevelAdminActive')

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("SensorAppOverview_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("SensorAppOverview_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("SensorAppOverview_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("SensorAppOverview_OnUserLevelAdminActive", status)
end

--- Function to get access to the sensorAppOverview_Model object
---@param handle handle Handle of sensorAppOverview_Model object
local function setSensorAppOverview_Model_Handle(handle)
  sensorAppOverview_Model = handle
  if sensorAppOverview_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if sensorAppOverview_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("SensorAppOverview_OnUserLevelAdminActive", true)
    Script.notifyEvent("SensorAppOverview_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("SensorAppOverview_OnUserLevelServiceActive", true)
    Script.notifyEvent("SensorAppOverview_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrSensorAppOverview()

  updateUserLevel()

  -- Script.notifyEvent("SensorAppOverview_OnNewEvent", false)

  Script.notifyEvent("SensorAppOverview_OnNewStatusLoadParameterOnReboot", sensorAppOverview_Model.parameterLoadOnReboot)
  Script.notifyEvent("SensorAppOverview_OnPersistentDataModuleAvailable", sensorAppOverview_Model.persistentModuleAvailable)
  Script.notifyEvent("SensorAppOverview_OnNewParameterName", sensorAppOverview_Model.parametersName)
  -- ...
end
Timer.register(tmrSensorAppOverview, "OnExpired", handleOnExpiredTmrSensorAppOverview)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrSensorAppOverview:start()
  return ''
end
Script.serveFunction("CSK_SensorAppOverview.pageCalled", pageCalled)

--[[
local function setSomething(value)
  _G.logger:info(nameOfModule .. ": Set new value = " .. value)
  sensorAppOverview_Model.varA = value
end
Script.serveFunction("CSK_SensorAppOverview.setSomething", setSomething)
]]

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name: " .. tostring(name))
  sensorAppOverview_Model.parametersName = name
end
Script.serveFunction("CSK_SensorAppOverview.setParameterName", setParameterName)

local function sendParameters()
  if sensorAppOverview_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(sensorAppOverview_Model.helperFuncs.convertTable2Container(sensorAppOverview_Model.parameters), sensorAppOverview_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, sensorAppOverview_Model.parametersName, sensorAppOverview_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send SensorAppOverview parameters with name '" .. sensorAppOverview_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_SensorAppOverview.sendParameters", sendParameters)

local function loadParameters()
  if sensorAppOverview_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(sensorAppOverview_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      sensorAppOverview_Model.parameters = sensorAppOverview_Model.helperFuncs.convertContainer2Table(data)
      -- If something needs to be configured/activated with new loaded data, place this here:
      -- ...
      -- ...

      CSK_SensorAppOverview.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_SensorAppOverview.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  sensorAppOverview_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_SensorAppOverview.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    sensorAppOverview_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      sensorAppOverview_Model.parametersName = parameterName
      sensorAppOverview_Model.parameterLoadOnReboot = loadOnReboot
    end

    if sensorAppOverview_Model.parameterLoadOnReboot then
      loadParameters()
    end
    Script.notifyEvent('SensorAppOverview_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setSensorAppOverview_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

