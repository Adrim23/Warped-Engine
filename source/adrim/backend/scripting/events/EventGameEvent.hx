package adrim.backend.scripting.events;

import adrim.backend.chart.ChartData;
final class EventGameEvent extends CancellableEvent {
	public var event:ChartEvent;

    override public function new(ev:ChartEvent)
    {
        super();
        event = ev;
    }
}