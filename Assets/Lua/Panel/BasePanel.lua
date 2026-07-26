Object:subClass("BasePanel")

BasePanel.panelObj = nil
-- 模拟字典，控件名-控件类型名-控件（字典套字典）
BasePanel.controls = {}
-- 事件监听标识
BasePanel.isInitEvent = false

-- 存储控件到controls
function BasePanel:Init(name)
    if self.panelObj == nil then
        -- 实例化对象（从ui包中加载）
        self.panelObj = ABMgr:LoadRes("ui", name, typeof(GameObject))
        self.panelObj.transform:SetParent(Canvas, false)

        -- 存储控件到controls
        local allControls = self.panelObj:GetComponentsInChildren(typeof(UIBehaviour))
        -- 控件命名规则
        for i = 0, allControls.Length-1 do
            local controlName = allControls[i].name
            if string.find(controlName, "btn") ~= nil or 
               string.find(controlName, "tog") ~= nil or 
               string.find(controlName, "img") ~= nil or 
               string.find(controlName, "sv") ~= nil or
               string.find(controlName, "txt") ~= nil then
                local typeName = allControls[i]:GetType().Name

                -- 字典套字典
                if self.controls[controlName] ~= nil then
                    self.controls[controlName][typeName] = allControls[i]
                else
                    self.controls[controlName] = {[typeName] = allControls[i]}
                end
            end
        end
    end
end

-- 获取控件
function BasePanel:GetControl(name, typeName)
    if self.controls[name] ~= nil then
        local sameNameControls = self.controls[name]
        if sameNameControls[typeName] ~= nil then
            return sameNameControls[typeName]
        end
    end
    return nil
end

function BasePanel:ShowMe(name)
    self:Init(name)
    self.panelObj:SetActive(true)
end

function BasePanel:HideMe()
    self.panelObj:SetActive(false)
end
