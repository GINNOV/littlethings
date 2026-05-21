class Ending {
	static NONE = {description: 'none - game ongoing', className: ''};
	static ACCOLADES_WIN = {description: 'won by accolades', className: 'end_good'};
	static REBUKE_LOST = {description: 'lost by rebukes', className: 'end_bad'};
	static GATE_SECRET_BAD = {description: 'gate secret, bad', className: 'end_bad'};
	static GATE_SECRET_GOOD = {description: 'gate secret, good', className: 'end_good'};
	static GATE_REPORTED_END = {description: 'gate, reported', className: 'end_good'};
	static TELEPORTED_TO_WEST = {description: 'teleported to west', className: 'end_good'};
	static ESCAPED_TO_WEST = {description: 'escaped to west', className: 'end_good'};
	static CAUGHT_ESCAPING_TO_WEST = {description: 'caught escaping to west', className: 'end_bad'};
	static GATE_BAD_TELEPORTED_TO_WEST = {description: 'gate secret, bad, teleported to the west', className: 'end_good'};
}
