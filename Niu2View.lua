-- @Author: ZhuL
-- @Date:   2017-05-18 15:54:18
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-06-16 14:41:15


local BaseView = require_ex("games.niu2.views.BaseView")
local M = class("Niu2View", BaseView)

local TAG_CHIP = -100

local State = {
    Ready = 1,
    Player1Rob = 2,
    Player2Rob = 3,
    WaitBet = 4,    -- 等待押注
    WaitSettle = 5,  -- 等待亮牌
    Idle = 6
}


function M:ctor(ctrler , roomId)
    BaseView.ctor(self)

    self._root = nil

    self._roomId = roomId

    self._time = 1

    self._btnDelay = 0

    self._widget = {}

    self._ctrler = ctrler

    self._DB = ctrler:getDB()

    self._chips = {}

    self._idTab = {}

    self:init()
end

function M:init()
    self:initWidget()
    self:initView()
end

function M:onEnter()
    Game.connectHandler:setHeartBeatInterval(20)
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION_3D)
    playNiuSound("DoubleBullUI>bgm")
    BaseView.onEnter(self)
end

function M:onExit()
    Game.connectHandler:setHeartBeatInterval(60)
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION_2D)
    BaseView.onExit(self)
end

function M:getChipsNum()
    local count = 0
    local children = self._widget.panel:getChildren()
    for __ , child in ipairs(children) do
        if child:getName() == "imgChip" then
            count = count + 1
        end
    end
    return count
end

function M:onTrans(sender , event)
    if self._btnDelay < 1 then
        return
    end
    self._btnDelay = 0
    if self:getChipsNum() > 0 then
        Game:tipMsg("游戏中不能换桌")
        return
    end
    self._ctrler:reqTrans()
end

function M:initWidget()
    self._root = createCsbNode("subgame/Niu2/bullView2.csb")
    self:addChild(self._root)
    local tab = {
        ["bullTitle"] = {key = "bullTitle"},
        ["panel"] = {key = "panel"},
        ["panel/txtTitle"] = {key = "txtTitle"},
        ["panel/pointAnim"] = {
            key = "pointAnimStart",
            spine = {
                res = "subgame/Niu2/spine/start/nn_go",
                bVisible = false
                -- anim = {"1" , "2"},
                -- bLastLoop = true
            }
        },
        ["panel/panelBet/txtBet"] = {key = "txtBet"},
        ["panel/panelBet"] = {key = "panelBet"},
        ["poker"] = {key = "poker"},
        ["imgChip"] = {key = "imgChip"},
        ["panel/seat1"] = {key = "seat1" , handle = handler(self , self.onSeatClicked)},
        ["panel/seat1/pointAnim"] = {
            key = "pointAnim1",
            spine = {
                res = "subgame/Niu2/spine/zhuan/nn_zhuang",
                -- anim = {"1" , "2"},
                -- bLastLoop = true
            }
        },
        ["panel/seat2"] = {key = "seat2" , handle = handler(self , self.onSeatClicked)},
        ["panel/seat2/pointAnim"] = {
            key = "pointAnim2" ,
            spine = {
                res = "subgame/Niu2/spine/zhuan/nn_zhuang",
                -- anim = {"1" , "2"},
                -- bLastLoop = true
            }
        },
        ["panel/panelInfo"] = {key = "panelInfo"},
        ["panel/txtWaitNext"] = {key = "txtWaitNext"},
        ["panel/panelInfo/txtName1"] = {key = "txtName1"},
        ["panel/panelInfo/txtPre1"] = {key = "txtPre1"},
        ["panel/panelInfo/txtTotal1"] = {key = "txtTotal1"},
        ["panel/panelInfo/txtName2"] = {key = "txtName2"},
        ["panel/panelInfo/txtPre2"] = {key = "txtPre2"},
        ["panel/panelInfo/txtTotal2"] = {key = "txtTotal2"},

        ["panel/panelTime"] = {key = "panelTime"},
        ["panel/panelTime/img1"] = {key = "timeBg"},
        ["panel/panelTime/txtTime"] = {key = "txtTime"},
        ["panel/panelTime/txtTips"] = {key = "txtTips"},
        ["panel/ready"] = {key = "ready"},
        ["panel/ready/btnRob"] = {key = "btnRob" , handle = handler(self , self.onRobClicked)},
        ["panel/ready/btnNotRob"] = {key = "btnNotRob" , handle = handler(self , self.onNotRobClicked)},
        ["panel/ready/btnReady"] = {key = "btnReady" , handle = handler(self , self.onReadyClicked)},

        ["panel/selectBet"] = {key = "selectBet"},
        ["panel/selectBet/btn1"] = {key = "btn1" , handle = handler(self , self.onBetClicked)},
        ["panel/selectBet/btn2"] = {key = "btn2" , handle = handler(self , self.onBetClicked)},
        ["panel/selectBet/btn3"] = {key = "btn3" , handle = handler(self , self.onBetClicked)},
        ["panel/selectBet/btn4"] = {key = "btn4" , handle = handler(self , self.onBetClicked)},
        ["panel/selectBet/btn5"] = {key = "btn5" , handle = handler(self , self.onBetClicked)},

        ["panel/start"] = {key = "start"},
        ["panel/start/pokers1"] = {key = "pokers1"},
        ["panel/start/pokers1/imgPoint"] = {
            key = "imgPoint1",
            spine = {
                res = "subgame/Niu2/spine/paixing/cm/nn_pok_nn",
                anim = "1",
                x = 112,
                y = 20
            }
        },
        ["panel/start/pokers2"] = {key = "pokers2"},
        ["panel/start/pokers2/imgPoint"] = {
            key = "imgPoint2",
            spine = {
                res = "subgame/Niu2/spine/paixing/cm/nn_pok_nn",
                anim = "1",
                x = 112,
                y = 20
            }
        },
        ["panel/start/btnShow"] = {key = "btnShow" , handle = handler(self , self.onShowClicked)},

    }
    bindWidgetList(self._root , tab , self._widget)
    local widget = self._widget
    widget.pointAnim1:setVisible(false)
    widget.pointAnim2:setVisible(false)
    widget.seat1:getChildByName("imgLight"):setVisible(false)
    widget.seat2:getChildByName("imgLight"):setVisible(false)
    self:bindTitle(self._widget)
    widget.txtWaitNext:setVisible(false)

    self._widget.txtTitle:setString(DouniuRoomConfig.name(self._roomId))
    self._pos1 = cc.p(widget.panelTime:getPosition())
    self._pos2 = cc.p(self._pos1.x , self._pos1.y - 150)

    self._posL = cc.p(widget.txtTips:getPosition())
    self._posR = cc.p(self._posL.x + 60 , self._posL.y + 65)

    self._widget.panelTime:setVisible(false)
    self._widget.panelTime:setLocalZOrder(3)
    self._widget.txtBet:setString("")
    self:initPokers(self._widget.pokers1)
    self:initPokers(self._widget.pokers2)
    self:initClock()
    self:hideAllOp()
    self:refresh()

    widget.panelBet:setLocalZOrder(10)

    self:schedule(handler(self , self.updateTips) , 1)
    self:scheduleUpdate()
end

local arr = {
    [1] = ".",
    [2] = "..",
    [3] = "...",
    [4] = "....",
    [5] = ".....",
    [6] = "......",
}

function M:updateFunc(dt)
    self._btnDelay = self._btnDelay + dt
end

function M:updateTips(dt)
    self._time = self._time + 1
    local index = self._time % 6 + 1
    local widget = self._widget
    local str = "游戏即将开始" .. arr[index]
    widget.txtWaitNext:setString(str)
end

-- 刷新统计数据
function M:refreshRecord()
    local widget = self._widget
    local mySettle = self._DB:getMyRecord() or {}
    local cmpSettle = self._DB:getCmpttRecord() or {}

    local myData = self._DB:getMyData()
    -- local cmpData = self._DB:getComptitorData()

    widget.txtName1:setString(mySettle.name or myData.name or "")

    widget.txtName2:setString(cmpSettle.name or "")

    setRangeCoin(widget.txtPre1 , mySettle.last or 0)
    setRangeCoin(widget.txtTotal1 , mySettle.total or 0)
    setRangeCoin(widget.txtPre2 , cmpSettle.last or 0)
    setRangeCoin(widget.txtTotal2 , cmpSettle.total or 0)

end



function M:hideAllOp()
    local widget = self._widget
    widget.ready:setVisible(false)
    widget.selectBet:setVisible(false)
    widget.start:setVisible(false)
    widget.btnShow:setVisible(false)
end

function M:initClock()
    local resPgs = "subgame/Niu2/board/pn_back_7.png"
    local widget = self._widget
    local clock = cc.ProgressTimer:create(cc.Sprite:create(resPgs))
    clock:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    clock:setPosition(widget.timeBg:getPosition())
    widget.panelTime:addChild(clock , 10)
    widget.clock = clock
end

function M:breakCountTime()
    local widget = self._widget
    widget.panelTime:setVisible(false)
    widget.clock:stopAllActions()
end

function M:countTime(time , strTips , bShow)
    time = time - 1
    strTips = strTips or ""
    local widget = self._widget
    widget.panelTime:setVisible(true)
    widget.txtTime:setString(time)
    local function playSound(time)
        if time > 2 then
            return
        end
        if time > 0 then
            playNiuSound("DoubleBullUI>countdown")
        else
            playNiuSound("DoubleBullUI>countdown2")
        end
    end
    playSound(time)
    local arr = {}
    for i = 1 , time do
        local seq = cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(function(node)
                time = time - 1
                playSound(time)
                widget.txtTime:setString(time)
            end)
        )
        table.insert(arr , seq)
    end
    table.insert(arr , cc.DelayTime:create(1))
    table.insert(arr , cc.CallFunc:create(function()
        widget.panelTime:setVisible(false)
    end))
    widget.txtTips:setString(strTips)
    local progressTo = cc.ProgressTo:create(time , 0)
    widget.clock:stopAllActions()
    widget.clock:setPercentage(100)
    widget.clock:runAction(cc.Sequence:create(arr))
    widget.clock:runAction(progressTo)
    if bShow then
        widget.panelTime:setPosition(self._pos2)
        widget.txtTips:setPosition(self._posR)
        widget.clock:setVisible(false)
        widget.timeBg:setVisible(false)
    else
        widget.panelTime:setPosition(self._pos1)
        widget.txtTips:setPosition(self._posL)
        widget.clock:setVisible(true)
        widget.timeBg:setVisible(true)
    end
end

function M:initPokers(panelPoker)
    for __ , child in ipairs(panelPoker:getChildren()) do
        if child:getName() ~= "imgPoint" then
            child:setScaleX(-1)
            child:getChildByName("imgBack"):setScaleX(-1)
            panelPoker.__pokerY = child:getPositionY()
        end
        child:setVisible(false)
    end
end

function M:refresh()
    self:refreshAllSeat()
    self:refreshChipButton()
    self:refreshRecord()
    self:refreshOp()
end

-- 所有选手就位
function M:onPlayerAll(time)
    self:refresh()

    self._widget.txtWaitNext:setVisible(false)
    local widget = self._widget
    widget.txtBet:setString("")
    widget.btnReady:setVisible(true)
    widget.btnNotRob:setVisible(false)
    widget.btnRob:setVisible(false)
    local pokers1 = widget.pokers1
    local pokers2 = widget.pokers2
    self:formatPokers(pokers1)
    self:formatPokers(pokers2)
    self:countTime(time , "请准备")
end

function M:onNoticeRobBanker(bCanRob , time)
    self:breakCountTime()
    local widget = self._widget
    self:refreshOp()
    self:refreshAllSeat()
    widget.btnReady:setVisible(false)
    widget.btnRob:setVisible(bCanRob)
    widget.btnNotRob:setVisible(bCanRob)
    local strTips = bCanRob and "是否抢庄？" or "等待对方选择"
    self:countTime(time , strTips)
end

function M:onConfirmBanker(time , bAnim)
    local uid = Game.playerDB:getPlayerUid()
    local banker = self._DB:getBanker()
    local widget = self._widget
    widget.btnNotRob:setVisible(false)
    widget.btnRob:setVisible(false)
    self:breakCountTime()
    local isBanker = uid == banker

    local delay = bAnim and 2 or 0

    local function cb()
        self:refreshOp()
        self:refreshAllSeat()
        local isBanker = uid == banker
        widget.selectBet:setVisible(not isBanker)
        local strTips = isBanker and "等待对方下注" or "请下注"
        self:countTime(time - delay , strTips)
    end

    if bAnim then
        self:bankerAnim(2 , cb , isBanker)
    else
        cb()
    end
end

function M:showWaitTips()
    local widget = self._widget
    widget.txtWaitNext:setVisible(true)
end

function M:bankerAnim(time , cb , bBanker)
    local widget = self._widget
    local l1 = widget.seat1:getChildByName("imgLight")
    local l2 = widget.seat2:getChildByName("imgLight")
    local p1 = widget.pointAnim1
    local p2 = widget.pointAnim2
    l1:loadTexture("subgame/Niu2/board/pn_bord_4.png")
    l2:loadTexture("subgame/Niu2/board/pn_bord_3.png")
    local seq = cc.Sequence:create(
        cc.CallFunc:create(function(node)
            l1:setVisible(true)
            l2:setVisible(false)
            playNiuSound("DoubleBullUI>run")
        end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function()
            l2:setVisible(true)
            l1:setVisible(false)
            playNiuSound("DoubleBullUI>run")
        end),
        cc.DelayTime:create(0.1)
    )
    local action = cc.RepeatForever:create(seq)
    self._action = action
    self:runAction(action)
    performWithDelay(self , function()
        self:stopAction(action)
        l1:setVisible(bBanker)
        l2:setVisible(not bBanker)
        p1:setVisible(bBanker)
        p2:setVisible(not bBanker)

        p1.__actor:changeAnimation("1" , false , nil , true)
        p2.__actor:changeAnimation("1" , false , nil , true)

    end , 1)
    performWithDelay(self , function()
        l1:setVisible(false)
        l2:setVisible(false)
        p1:setVisible(false)
        p2:setVisible(false)
        cb()
    end , 2)
end

function M:refreshAllSeat()
    local widget = self._widget
    local myData = self._DB:getMyData()
    local cmpData = self._DB:getComptitorData()
    self._idTab = {
        [myData.player_id] = widget.seat1,
        -- [cmpData.player_id] = widget.seat2
    }
    if cmpData ~= nil then
        self._idTab[cmpData.player_id] = widget.seat2
    end

    self:refreshSeat(widget.seat2 , cmpData)
    self:refreshSeat(widget.seat1 , myData)
end

function M:refreshSeat(seat , data)
    seat:getChildByName("imgBanker"):setVisible(false)
    if data == nil then
        seat:setVisible(false)
        -- self._widget.start:setVisible(false)
        return
    end
    print("dataisfull===================================")
    dump(data)
    seat:setVisible(true)
    seat:getChildByName("imgOk"):setVisible(data.isOK and self._ctrler:getGameState() == State.Ready)
    local banker = self._DB:getBanker()
    seat:getChildByName("imgBanker"):setVisible(banker ~= nil and banker == data.player_id)
    seat:getChildByName("txtCoin"):setString(data.coin)
    seat:getChildByName("txtName"):setString(data.name)
    seat:getChildByName("txtVip"):setString("VIP" .. data.vip_lv)
    seat:getChildByName("imgAvatar"):loadTexture(cfg_util.getFacelook(data.facelook))
end

function M:onPlayerReady(info)
    self:refreshAllSeat()
    local widget = self._widget
    local myData = self._DB:getMyData()
    local cmpData = self._DB:getComptitorData()
    widget.btnReady:setVisible(not myData.isOK)
    local bStart = myData.isOK and cmpData.isOK
    if not bStart then
        return
    end

    playNiuSound("DoubleBullUI>start")
    local actor = widget.pointAnimStart.__actor
    actor:setVisible(true)
    actor:changeAnimation("1" , false , nil , true)
end

function M:dispatchPoker(time)

    self:refreshAllSeat()
    self:refreshOp()
    local widget = self._widget
    local pokers1 = widget.pokers1
    local pokers2 = widget.pokers2
    self:formatPokers(pokers1)
    self:formatPokers(pokers2)
    widget.start:setVisible(true)
    widget.ready:setVisible(false)
    for i = 1 , 10 do
        local pokerFly = widget.poker:clone()
        self:addChild(pokerFly , 10 - i)
        pokerFly:moveVec2(0 , 2 * i)
        local panelPoker
        panelPoker = i % 2 == 0 and pokers1 or pokers2
        local index = math.ceil(i / 2)
        performWithDelay(self , function()
            self:flyPoker(panelPoker , pokerFly , index)
        end , 0.1 * i)
    end
    performWithDelay(self , function()
        widget.btnShow:setVisible(true)
        self:countTime(time - 2 , "请亮牌" , true)
        self:showPoker(pokers1)
    end , 2.5)

    local myCards = self._DB:getMyCards()
    self:setPokersLst(pokers1 , myCards)
end

function M:flyPoker(panelPoker , pokerFly , index)
    playNiuSound("DoubleBullUI>deal")
    local dur = 0.3
    local poker = panelPoker:getChildByName("poker" .. index)
    local targetPos = poker:getWorldPosition()
    local scale = panelPoker:getScale()
    local scaleBy = cc.ScaleBy:create(dur , scale)
    local moveTo = cc.MoveTo:create(dur , targetPos)
    local rotateBy = cc.RotateBy:create(dur , 360 * 1)
    local callFunc = cc.CallFunc:create(function(node)
        node:removeFromParent()
        poker:setVisible(true)
    end)
    local seq = cc.Sequence:create(cc.Spawn:create(scaleBy , moveTo , rotateBy) , callFunc)
    pokerFly:runAction(seq)
end

-- 亮牌动作
function M:showPoker(panelPoker , bShowPoint , avatarId)
    local pokers = {}
    for __ , child in ipairs(panelPoker:getChildren()) do
        if child:getName() ~= "imgPoint" then
            table.insert(pokers , child)
        end
    end
    local time = 0.0
    for i , poker in ipairs(pokers) do
        local imgBack = poker:getChildByName("imgBack")
        if imgBack:isVisible() then
            poker:getChildByName("imgBack"):setVisible(true)
            local seq = cc.Sequence:create({
                cc.DelayTime:create(time * (i - 1)),
                cc.OrbitCamera:create(0.25, 1, 0, 0, 90, 0, 0),
                cc.CallFunc:create(function(node)
                    node:getChildByName("imgBack"):setVisible(false)
                end),
                cc.OrbitCamera:create(0.25, 1, 0, 90, 90, 0, 0),
            })
            poker:runAction(seq)
        end
    end

    if not bShowPoint then
        return
    end
    performWithDelay(self , function()
        self:showPoint(panelPoker , avatarId)
    end , 0.5)
end

function M:showPoint(panelPoker , avatarId)
    local pokerLst = panelPoker:getXData()
    if pokerLst == nil then
        return
    end
    local nums = {}
    for i , card in ipairs(pokerLst) do
        nums[i] = card.size
    end
    local lst , point = getValueIndexAndPoint(nums)
    playNiuSound("DoubleBullUI>niu" , avatarId , point)
    for i = 1 , 5 do
        local poker = panelPoker:getChildByName("poker" .. i)
        if lst[i] ~= nil then
            local args = {
                x = 0,
                y = 12,
                time = 0.3
            }
            poker:moveBy(args)
        end
    end
    local pointRes = getCardsPointRes(point)
    local imgPoint = panelPoker:getChildByName("imgPoint")
    local actor = imgPoint.__actor
    if actor then
        actor:setVisible(point >= 10)
        actor:changeAnimation("1" , false , nil , true)
    end
    imgPoint:loadTexture(pointRes)
    imgPoint:setVisible(true)
end

function M:formatPokers(panelPoker)
    local y = panelPoker.__pokerY
    for i = 1 , 5 do
        local poker = panelPoker:getChildByName("poker" .. i)
        poker:setPositionY(y)
        poker:setVisible(false)
        poker:getChildByName("imgBack"):setVisible(true)
    end
    panelPoker:getChildByName("imgPoint"):setVisible(false)
end

function M:onResult(info)

end

function M:setPokersLst(panelPoker , pokerLst)
    for i , val in ipairs(pokerLst) do
        local poker = panelPoker:getChildByName("poker" .. i)
        setColorAndNum(poker , val.color , val.size)
    end
    pokerLst = clone(pokerLst)
    panelPoker:setXData(pokerLst)
    dump(pokerLst)
end

function M:onShowClicked(sender , event)
    local widget = self._widget
    widget.btnShow:setVisible(false)
    self:breakCountTime()
    self._ctrler:reqShow()
end

function M:onPlayerShow(info)
    local widget = self._widget
    local uid = Game.playerDB:getPlayerUid()
    local pokers = info.player_id == uid and widget.pokers1 or widget.pokers2
    local myData = self._DB:getMyData()
    local cmpData = self._DB:getComptitorData()
    local avatarId
    if info.player_id == uid then
        widget.btnShow:setVisible(false)
        avatarId = myData.facelook
    else
        avatarId = cmpData.facelook
    end
    self:setPokersLst(pokers , info.cards)
    self:showPoker(pokers , true , avatarId)
end

function M:onBetClicked(sender , event)
    local num = sender:getXData()
    self._ctrler:reqBet(num)
end

function M:onPlayerBet(uid , num , callback,status)
    local widget = self._widget
    self:refreshAllSeat()
    if status == nil then
    widget.txtBet:setString(num)
    widget.txtBet:setVisible(true)
    end

    local i = 0
    local seat = self._idTab[uid]
    local flag = true
    local count = 0
    while num > 0 do
        local val = num % 10
        num = math.floor(num / 10)
        print(val)
        for j = 1 , val do
            if flag then
                self:moveChipToDesk(seat , i , callback)
                flag = false
            else
                self:moveChipToDesk(seat , i)
            end
            count = count + 1
        end
        i = i + 1
    end
    widget.selectBet:setVisible(false)
    self:breakCountTime()
    if count > 3 then
        playNiuSound("DoubleBullUI>chipdown")
    else
        playNiuSound("DoubleBullUI>chip")
    end
end



function M:moveChipToDesk(seat , pow , callback)
    if type(seat) == "number" then
        seat = self._idTab[seat]
    end
    print("moveChipToDesk")
    dump(self._idTab)
    local key = "chip10^" .. pow
    local res = NiuResConfig.res(key)
    local widget = self._widget
    local chip = widget.imgChip:clone()
    local x = 195
    local y = 100
    local sPos = cc.p(common_util.rand(display.cx - x , display.cx + x),
                      common_util.rand(display.cy - y , display.cy + y))
    chip:setPosition(seat:getPosition())
    chip:loadTexture(res)
    chip:setTag(TAG_CHIP)
    widget.panel:addChild(chip , 1)
    local dur = 0.5
    local rot = common_util.rand(0 , 360)
    local rotateBy = cc.RotateBy:create(dur , rot)
    local moveTo = cc.EaseIn:create(cc.MoveTo:create(dur , sPos) , 0.2)
    local callFunc = cc.CallFunc:create(function(node)
        execute(callback , self)
    end)
    chip:runAction(cc.Sequence:create(cc.Spawn:create(moveTo , rotateBy) , callFunc))
end

function M:onSeatClicked(sender , event)
    local children = self._widget.panel:getChildren()
    for __ , child in ipairs(children) do
        if child:getName() == "imgChip" then
            self:__moveChipToSeat(child , sender)
        end
    end
end

function M:moveChipsToSeat(uid , callback)
    local seat = self._idTab[uid]
    local flag = true
    local count = 0
    local children = self._widget.panel:getChildren()
    for __ , child in ipairs(children) do
        if child:getName() == "imgChip" then
            if flag then
                self:__moveChipToSeat(child , seat , callback)
                flag = false
            else
                self:__moveChipToSeat(child , seat)
            end
            count = count + 1
        end
    end
    if count > 3 then
        playNiuSound("DoubleBullUI>chipdown")
    else
        playNiuSound("DoubleBullUI>chip")
    end
end

function M:__moveChipToSeat(chip , seat , callback)
    local dur = 0.5
    local pos = seat:getWorldPosition()
    local moveTo = cc.MoveTo:create(dur , pos)
    moveTo = cc.EaseBackIn:create(moveTo)
    chip:runAction(cc.Sequence:create(moveTo , cc.CallFunc:create(function(node)
        node:removeFromParent()
        execute(callback , self)
    end)))
end

function M:refreshOp()
    local widget = self._widget
    local state = self._ctrler:getGameState()
    local uid = Game.playerDB:getPlayerUid()
    local banker = self._DB:getBanker()
    local cmpData = self._DB:getComptitorData()
    print("state--------------------------------------" , state)
    widget.ready:setVisible(state == State.Ready or
                            state == State.Player2Rob or
                            state == State.Player1Rob)

    if state == State.Idle then
        widget.txtBet:setString("")
    end

    widget.btnReady:setVisible(state == State.Ready)

    widget.selectBet:setVisible(state == State.WaitBet and
                                banker ~= uid)
    widget.start:setVisible(state == State.WaitSettle and cmpData ~= nil)
end

function M:onRobClicked(sender , event)
    self._ctrler:reqRobBanker(true)
    local widget = self._widget
    widget.ready:setVisible(false)
end

function M:onNotRobClicked(sender , event)
    self._ctrler:reqRobBanker(false)
    local widget = self._widget
    widget.ready:setVisible(false)
end

function M:onReadyClicked(sender , event)
    local widget = self._widget
    widget.btnReady:setVisible(false)
    self:breakCountTime()
    self._ctrler:reqReady()
end

function M:initView()
    self:refreshChipButton()
end

function M:refreshChipButton()
    local lst = self._ctrler:getChipValueLst()
    local widget = self._widget

    for i , num in ipairs(lst) do
        local btn = widget["btn" .. i]
        btn:setTitleString(adapterUnit(num , "\n"))
        btn:setXData(num)
    end
end

function M:onClose()
    if self._btnDelay < 1 then
        return
    end
    self._btnDelay = 0
    if self:getChipsNum() > 0 then
        Game:tipMsg("游戏中不能退出")
        return
    end
    self._ctrler:reqExitGame()
end

function M:destroy()
    Game:openGameWithIdx(SCENCE_ID.PLATEFORM, MoreGameView)
    BaseView.destroy(self)
end

return M