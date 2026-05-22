class Utils {
	static rgbToHex(r, g, b) {
		return '#' +
			('0' + r.toString(16)).slice(-2) +
			('0' + g.toString(16)).slice(-2) +
			('0' + b.toString(16)).slice(-2);
	}

	static clamp(x, min, max) {
		if (x < min) return min;
		if (x > max) return max;
		return x;
	}

	static chanceTrapezoid(curr, start, peakStart, peakEnd, end, min, max) {
		if(start < curr && curr < peakStart) {
			// Ascending ramp
			return min + ((max - min) * (curr - start)) / (peakStart - start);
		}
		if(peakStart <= curr && curr <= peakEnd) {
			// Peak
			return max;
		}
		if(peakEnd < curr && curr < end) {
			// Descending ramp
			return max - ((max - min) * (curr - peakEnd)) / (end - peakEnd);
		}
		// Out of range
		return min;
	}

	static shuffleArray(array, rand) {
		for (let i = array.length - 1; i > 0; i--) {
			const j = rand.next16Max(i - 1);
			[array[i], array[j]] = [array[j], array[i]];
		}
	}
}
