﻿package com.company.assembleegameclient.ui.menu {
import com.company.util.GraphicsUtil;
import com.company.util.RectangleUtil;
import com.company.assembleegameclient.game.GameSprite;

import flash.display.DisplayObjectContainer;
import flash.display.CapsStyle;
import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;

import kabam.rotmg.ui.view.UnFocusAble;

public class Menu extends Sprite implements UnFocusAble {

    private var backgroundFill_:GraphicsSolidFill = new GraphicsSolidFill(0, 1);
    private var outlineFill_:GraphicsSolidFill = new GraphicsSolidFill(0, 1);
    private var lineStyle_:GraphicsStroke = new GraphicsStroke(1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3, outlineFill_);
    private var path_:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());
    private var background_:uint;
    private var outline_:uint;
    protected var yOffset:int;

    private const graphicsData_:Vector.<IGraphicsData> = new <IGraphicsData>[lineStyle_, backgroundFill_, path_, GraphicsUtil.END_FILL, GraphicsUtil.END_STROKE];

    public function Menu(_arg1:uint, _arg2:uint) {
        super();
        this.background_ = _arg1;
        this.outline_ = _arg2;
        this.yOffset = 40;
        filters = [new DropShadowFilter(0, 0, 0, 1, 16, 16)];
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    protected function addOption(_arg1:MenuOption):void {
        _arg1.x = 8;
        _arg1.y = this.yOffset;
        addChild(_arg1);
        this.yOffset = (this.yOffset + 28);
    }

    protected function onAddedToStage(_arg1:Event):void {
        this.draw();
        this.position();
        addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
        addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
    }

    protected function onRemovedFromStage(_arg1:Event):void {
        removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
        removeEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
    }

    protected function onEnterFrame(_arg1:Event):void {
        if (stage == null) {
            return;
        }
        var _local2:Rectangle = getRect(stage);
        var _local3:Number = RectangleUtil.pointDist(_local2, stage.mouseX, stage.mouseY);
        if (_local3 > 40) {
            this.remove();
        }
    }

    public function scaleParent(param1:Boolean):void {
        var _loc2_:DisplayObjectContainer = null;
        if (this.parent is GameSprite) {
            _loc2_ = this;
        }
        else {
            _loc2_ = this.parent;
        }
        var _loc3_:Number = 800 / stage.stageWidth;
        var _loc4_:Number = 600 / stage.stageHeight;
        if (param1 == true) {
            _loc2_.scaleX = _loc3_ / _loc4_;
            _loc2_.scaleY = 1;
        }
        else {
            _loc2_.scaleX = _loc3_;
            _loc2_.scaleY = _loc4_;
        }
    }

    private function position():void {
        var _loc1_:Number;
        var _loc2_:Boolean = false;
        var _loc3_:Number = (stage.stageWidth - 800) / 2 + stage.mouseX;
        _loc1_ = (stage.stageHeight - 600) / 2 + stage.mouseY;
        var _loc4_:Number = 600 / stage.stageHeight;
        this.scaleParent(_loc2_);

        if (_loc2_) {
            _loc3_ = _loc3_ * _loc4_;
            _loc1_ = _loc1_ * _loc4_;
        }

        if (stage == null) {
            return;
        }

        if (stage.mouseX + 0.5 * stage.stageWidth - 400 < stage.stageWidth / 2) {
            this.x = _loc3_ + 12;
        } else {
            this.x = _loc3_ - width - 1;
        }

        if (this.x < 12) {
            this.x = 12;
        }

        if (stage.mouseY + 0.5 * stage.stageHeight - 300 < stage.stageHeight / 3) {
            this.y = _loc1_ + 12;
        } else {
            this.y = _loc1_ - height - 1;
        }

        if (this.y < 12) {
            this.y = 12;
        }
    }

    protected function onRollOut(_arg1:Event):void {
        this.remove();
    }

    public function remove():void {
        if (parent != null) {
            parent.removeChild(this);
        }
    }

    protected function draw():void {
        this.backgroundFill_.color = this.background_;
        this.outlineFill_.color = this.outline_;
        graphics.clear();
        GraphicsUtil.clearPath(this.path_);
        GraphicsUtil.drawCutEdgeRect(-6, -6, Math.max(154, (width + 12)), (height + 12), 4, [1, 1, 1, 1], this.path_);
        graphics.drawGraphicsData(this.graphicsData_);
    }
}
}

