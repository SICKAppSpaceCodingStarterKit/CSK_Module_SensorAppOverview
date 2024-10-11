---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_SensorAppOverview'

local sensorAppOverview_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
sensorAppOverview_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
sensorAppOverview_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
sensorAppOverview_Model.parametersName = 'CSK_SensorAppOverview_Parameter' -- name of parameter dataset to be used for this module
sensorAppOverview_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the SensorAppOverview_Model interface and give access
-- to the SensorAppOverview_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setSensorAppOverview_ModelHandle = require('System/SensorAppOverview/SensorAppOverview_Controller')
setSensorAppOverview_ModelHandle(sensorAppOverview_Model)

--Loading helper functions if needed
sensorAppOverview_Model.helperFuncs = require('System/SensorAppOverview/helper/funcs')

sensorAppOverview_Model.version = Engine.getCurrentAppVersion() -- Version of module
sensorAppOverview_Model.styleForUI = 'None' -- Optional parameter to set UI style
sensorAppOverview_Model.linkMainAppPrefix = '/#!msdd=' -- URL Prefix for MainApp link
sensorAppOverview_Model.editMode = false -- Show MainApp configuration
sensorAppOverview_Model.mainAppImage = nil -- Hold binary of MainApp image if available
sensorAppOverview_Model.mainAppName = Parameters.get('MainAppName') or '' -- Name of MainApp
sensorAppOverview_Model.configurationMode = 'Default' -- Mode of MainApp configuration mode ('Edit', 'Default')
sensorAppOverview_Model.mainAppMode = 'NoMainApp' -- MainApp mode ('MainAppNoImage', 'NoMainApp', 'MainAppImage')
sensorAppOverview_Model.appList = sensorAppOverview_Model.helperFuncs.createAppJsonList(Engine.listApps()) -- List of available apps

-- Prepare public folder structure
local dirExist = File.isdir('/public/HomeScreen')
if not dirExist then
  File.mkdir('/public/HomeScreen')
end

-- Check if MainApp image exist
local appImageExists = File.exists('/public/HomeScreen/MainApp.bin')
if not appImageExists then
  File.copy('/resources/CSK_Module_SensorAppOverview/MainApp.bin', '/public/HomeScreen/MainApp.bin')
end
local f = File.open("/public/HomeScreen/MainApp.bin", 'rb')
sensorAppOverview_Model.mainAppImage = f:read()
f:close()

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Function to setup MainApp mode
local function checkStatus()
  if sensorAppOverview_Model.mainAppName ~= '' then
    if sensorAppOverview_Model.mainAppImage then
      sensorAppOverview_Model.mainAppMode = 'MainAppImage'
    else
      sensorAppOverview_Model.mainAppMode = 'MainAppNoImage'
    end
  else
    sensorAppOverview_Model.mainAppMode = 'NoMainApp'
  end
end
sensorAppOverview_Model.checkStatus = checkStatus
checkStatus()

--- Function to set main app
---@param appName string Name of main app
local function setMainWebpage(appName)
  local defaultWebpage = Parameters.get("AEDefaultWebpage")
  if defaultWebpage == nil then
    assert(false, "AppEngine does not support setting the default webpage over variable AEDefaultWebpage")
  else
    assert(Parameters.set("AEDefaultWebpage", appName))
    sensorAppOverview_Model.mainAppName = appName
    Parameters.set('MainAppName', sensorAppOverview_Model.mainAppName)
    Parameters.savePermanent()
    checkStatus()
  end
end
sensorAppOverview_Model.setMainWebpage = setMainWebpage

local starterApp = Parameters.get('MainAppName')
local appCheck = false
local appList = Engine.listApps()
for key, _ in pairs(appList) do
  if appList[key] == starterApp then
    appCheck = true
  end
end

if appCheck then
  setMainWebpage(starterApp)
else
  setMainWebpage('CSK_Module_SensorAppOverview')
end

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return sensorAppOverview_Model
