classdef FigureEventDispatcher < handle
    %FIGUREEVENTDISPATCHER Dispatch user events from figure to callbacks
    %   User events such as mouse buttons up/down/move are only available
    %   for figures but not for axes. If you have multiple axes which need
    %   callbacks for keyboard or mouse, you need an event dispatcher which
    %   forwards figure events to axes-oriented objects such as
    %   gfx.internal.Orbit3d
    %
    %   matlab.ui.eventdata.WindowMouseData
    %   matlab.ui.eventdata.ScrollWheelData
    %   matlab.ui.eventdata.KeyData

    methods(Static)
        function setupFigureCallbacks(hFigure)
            arguments
                hFigure matlab.ui.Figure
            end
            
            hFigure.WindowButtonDownFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.WindowButtonMotionFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.WindowButtonUpFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.WindowScrollWheelFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.WindowKeyPressFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.WindowKeyReleaseFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.KeyPressFcn = @gfx.FigureEventDispatcher.eventCallback;
        end

        function uid = addEvent(eventName, fcn, hAxes, eventFilterFcn)
            arguments
                eventName {mustBeMember(eventName, ["WindowMousePress" "WindowMouseMotion" "WindowMouseRelease" "WindowKeyPress" "WindowKeyRelease" "KeyPress" "WindowScrollWheel"])}
                fcn   function_handle
                hAxes matlab.ui.control.UIAxes
                eventFilterFcn function_handle = @(~, ~)true
            end

            uid = randi(1e10);

            s.name = eventName;
            s.fcn = fcn;
            s.filterFcn = eventFilterFcn;
            s.uid = uid;

            if isfield(hAxes.UserData, 'UiEventList')
                hAxes.UserData.UiEventList = [hAxes.UserData.UiEventList s];
            else
                hAxes.UserData.UiEventList = s;
            end
        end

        function editEvent(hAxes, uid, fcn)
            arguments
                hAxes matlab.ui.control.UIAxes
                uid
                fcn   function_handle
            end
            idx = [hAxes.UserData.UiEventList.uid] == uid;
            assert(nnz(idx)==1, 'event not found or ambiguous')
            hAxes.UserData.UiEventList(idx).fcn = fcn;
        end
    end

    methods(Static, Hidden)
        function eventCallback(hFig, event)
            evList = hFig.CurrentAxes.UserData.UiEventList;

            tfEventName =  [evList.name] == event.EventName;
            tfEventFilter = arrayfun(@(x)(x.filterFcn(hFig, event)), evList);

            for k = find(tfEventName & tfEventFilter)
                fcn = evList(k).fcn;
                % disp("dispatch " + event.EventName + " to " + func2str(fcn))
                fcn(hFig, event);
            end
        end
    end
end