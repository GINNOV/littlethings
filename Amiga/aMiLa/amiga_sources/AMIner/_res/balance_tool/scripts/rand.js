class rand {
	constructor(seed1, seed2) {
		if(seed1 == 0 || seed2  == 0) {
			throw new Error("seed can't be zero");
		}

		this.state1 = seed1;
		this.state2 = seed2;
	}

	next16() {
		let t = (this.state1 ^ (this.state1 << this.COEFF_A)) & 0xFFFF;
		this.state1 = this.state2;
		this.state2 = ((this.state2 ^ (this.state2 >> this.COEFF_C)) ^ (t ^ (t >> this.COEFF_B))) & 0xFFFF;
		return this.state2;
	}

	next16Max(max) {
		return this.next16() % (max + 1);
	}

	next16MinMax(min, max) {
		return min + this.next16Max(max - min);
	}

	next32() {
		let upper = this.next16();
		let lower = this.next16();
		return (upper << 16) | (lower);
	}

	next32Max(max) {
		return this.next32() % (max + 1);
	}

	next32MinMax(min, max) {
		return min + this.next32Max(max - min);
	}

	COEFF_A = 5;
	COEFF_B = 7;
	COEFF_C = 4;
}
