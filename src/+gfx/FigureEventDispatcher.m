classdef FigureEventDispatcher < handle
    %FIGUREEVENTDISPATCHER Dispatch user events from figure to axes
    %   User events such as mouse buttons up/down/move are only available
    %   for figures but not for axes. If you have multiple axes or multiple
    %   listeners for the same axes which need callbacks for keyboard or
    %   mouse, you need an event dispatcher which forwards figure events to
    %   axes-oriented objects such as gfx.orbit3d()
    %
    %   If global figure events are needed, you must use addFigureEvent()
    %   rather than directly assign the callbacks to the figure
    %
    %   The following Matlab figure event can be added for each axes
    %      WindowMousePress
    %      WindowMouseMotion
    %      WindowMouseRelease
    %      WindowKeyPress
    %      WindowKeyRelease
    %      KeyPress
    %      KeyRelease
    %      WindowScrollWheel
    %
    %   You may register a new event to an
    %   - axes object: event is only fired for current axes
    %   - figure object: event is always fired
    %
    %   CONSTRAINTS
    %       UserData of both axes an figure must be a struct. If you want
    %       to add additional data, you need to add a field to the struct
    %       UserData
    %
    %   EXAMPLE
    %      Create figure with two axes. Clicking on axes1 prints "axes1
    %      clicked", clicking on axes2 prints "axes2 clicked". Pressing a
    %      key no matter which axes is selected prints "key pressed"
    %
    %      hGrid = uigridlayout;
    %      hAxes1 = uiaxes("Parent", hGrid);
    %      hAxes2 = uiaxes("Parent", hGrid);
    %      gfx.FigureEventDispatcher.setupFigureCallbacks(hGrid.Parent)
    %      gfx.FigureEventDispatcher.addAxesEvent("WindowMousePress", @(hFig, event)disp("axes1 clicked"), hAxes1);
    %      gfx.FigureEventDispatcher.addAxesEvent("WindowMousePress", @(hFig, event)disp("axes2 clicked"), hAxes2);
    %      gfx.FigureEventDispatcher.addFigureEvent("KeyPress", @(hFig, event)disp("key pressed"), hGrid.Parent);
    %
    %   EXAMPLE disable/enable events
    %      Disable events
    %         eventList = hAxes.UserData.UiEventList;
    %         keypressUid = eventList([eventList.name] == "KeyPress").uid;
    %         gfx.FigureEventDispatcher.disableEvent(hAxes, keypressUid)
    %
    %      Re-enable events
    %         gfx.FigureEventDispatcher.enableEvent(hAxes, keypressUid)
    %
    %   AUTHOR
    %     Copyright 2023-2025, Markus Leuthold, markus.leuthold@sonova.com
    %
    %   LICENSE
    %     BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)

    methods(Static)
        function setupFigureCallbacks(hFigure)
            % The field UiEventList needs to be available for
            % hFigure.UserData and hFigure.CurrentAxes.UserData
            %
            % addFigureEvent() is a custom function and not called within
            % gfx.orbit3d(). Hence the field UiEventList needs to be added
            % in setupFigureCallbacks().
            %
            % addAxesEvent() is called in orbit3d(), implicitly adding the
            % field UiEventList.
            arguments
                hFigure matlab.ui.Figure = gcf
            end

            assert(isempty(hFigure.UserData) || isstruct(hFigure.UserData), ...
                'UserData must be a struct. If you need to add your own data, add it to a new field of the struct UserData');

            % Currently, it is not foreseen to reset the field UiEventList
            % in hFigure.UserData. Previously added figure events are preserved
            if ~isfield(hFigure.UserData, 'UiEventList')
                hFigure.UserData.UiEventList = [];
            end

            % If datacursor mode is enabled, no callbacks can be set
            dcm = datacursormode(hFigure);
            if dcm.Enable
                dcm.Enable = "off";
            end

            hFigure.WindowButtonDownFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.WindowButtonMotionFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.WindowButtonUpFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.WindowScrollWheelFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.WindowKeyPressFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.WindowKeyReleaseFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.KeyPressFcn = @gfx.FigureEventDispatcher.eventCallback;
            hFigure.KeyReleaseFcn = @gfx.FigureEventDispatcher.eventCallback;
        end

        function uid = addAxesEvent(eventName, fcn, hAxes, eventFilterFcn)
            arguments
                eventName {mustBeMember(eventName, ["WindowMousePress" "WindowMouseMotion" "WindowMouseRelease" "WindowKeyPress" "WindowKeyRelease" "KeyPress" "KeyRelease" "WindowScrollWheel"])}
                fcn function_handle  % callback @(hFig, event), event is one of
                %                      matlab.ui.eventdata.WindowMouseData
                %                      matlab.ui.eventdata.ScrollWheelData
                %                      matlab.ui.eventdata.KeyData
                hAxes matlab.graphics.axis.Axes
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

        function uid = addFigureEvent(eventName, fcn, hFigure, eventFilterFcn)
            arguments
                eventName {mustBeMember(eventName, ["WindowMousePress" "WindowMouseMotion" "WindowMouseRelease" "WindowKeyPress" "WindowKeyRelease" "KeyPress" "KeyRelease" "WindowScrollWheel"])}
                fcn function_handle  % callback @(hFig, event), event is one of
                %                      matlab.ui.eventdata.WindowMouseData
                %                      matlab.ui.eventdata.ScrollWheelData
                %                      matlab.ui.eventdata.KeyData
                hFigure matlab.ui.Figure
                eventFilterFcn function_handle = @(~, ~)true
                % eventFilterFcn takes the same two input params as the
                % second parameter "fcn". The function must return a
                % logical value: true if the event is accepted, false if
                % the event is rejected
            end

            uid = randi(1e10);

            s.name = eventName;
            s.fcn = fcn;
            s.filterFcn = eventFilterFcn;
            s.uid = uid;

            % Existence of UiEventList is guaranteed in setupFigureCallbacks
            hFigure.UserData.UiEventList = [hFigure.UserData.UiEventList s];
        end

        function editEvent(hObj, uid, fcn)
            arguments
                hObj
                uid
                fcn   function_handle
            end
            idx = [hObj.UserData.UiEventList.uid] == uid;
            if ~any(idx)
                assert(isfield(hObj.UserData, 'DisabledUiEventList'), 'Event does not exist')
                idx = [hObj.UserData.DisabledUiEventList.uid] == uid;
                assert(nnz(idx)==1, nnz(idx) + " disabled events found, one expected: ambiguous")
                hObj.UserData.DisabledUiEventList(idx).fcn = fcn;
            else
                assert(nnz(idx)==1, nnz(idx) + " events found, one expected: ambiguous")
                hObj.UserData.UiEventList(idx).fcn = fcn;
            end
        end

        function deleteEvent(hObj, uids)
            idx = ismember([hObj.UserData.UiEventList.uid], uids);
            hObj.UserData.UiEventList(idx) = [];
        end

        function disableEvent(hObj, uids)
            arguments
                hObj {mustBeA(hObj, {'matlab.graphics.axis.Axes' 'matlab.ui.control.UIAxes' 'matlab.ui.Figure'})}
                uids (1,:)
            end

            if isfield(hObj.UserData, 'DisabledUiEventList')
                isDisabled = ismember(uids, [hObj.UserData.DisabledUiEventList.uid]);
                uids = uids(~isDisabled);
            else
                hObj.UserData.DisabledUiEventList = [];
            end

            idx = ismember([hObj.UserData.UiEventList.uid], uids);
            hObj.UserData.DisabledUiEventList = [hObj.UserData.DisabledUiEventList hObj.UserData.UiEventList(idx)];
            hObj.UserData.UiEventList(idx) = [];
        end

        function enableEvent(hObj, uids)
            idx = ismember([hObj.UserData.DisabledUiEventList.uid], uids);
            hObj.UserData.UiEventList = [hObj.UserData.UiEventList hObj.UserData.DisabledUiEventList(idx)];
        end
    end

    methods(Static, Hidden)
        function eventCallback(hFig, event)
            % performance-critical

            % It is assumed there are axes events from orbit3d(). Without
            % any axes events (=non existing UiEventList on the axes), this
            % would fail.
            evList = [hFig.UserData.UiEventList hFig.CurrentAxes.UserData.UiEventList];

            tfEventName =  [evList.name] == event.EventName;
            tfEventFilter = false(1, numel(tfEventName));
            tfEventFilter(tfEventName) = arrayfun(@(x)(x.filterFcn(hFig, event)), evList(tfEventName));

            for k = find(tfEventName & tfEventFilter)
                fcn = evList(k).fcn;
                % disp("dispatch " + event.EventName + " to " + func2str(fcn))
                fcn(hFig, event);
            end
        end
    end
end