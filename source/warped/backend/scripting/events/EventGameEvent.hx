package warped.backend.scripting.events;

import warped.backend.chart.ChartData;
final class EventGameEvent extends CancellableEvent {
	public var event:ChartEvent;

    override public function new(ev:ChartEvent)
    {
        super();
        event = ev;
    }
}