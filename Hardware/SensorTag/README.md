# SensorTag

Experiments for collecting data from a TI SensorTag with a Raspberry Pi, Python, JavaScript, Redis, and background jobs.

## Files

| File | Purpose |
| --- | --- |
| `logger.js` | JavaScript logger experiment. |
| `qlogger.js` | Queue-based logger experiment. |
| `simplejob.js` | Minimal job queue example. |
| `read_temp.py` | Python temperature-reading helper. |
| `sensor_calcs.py` | Sensor calculation helpers. |
| `sensortag.py` | Python SensorTag access code. |
| `package.json` | Older Node dependencies for the JavaScript experiments. |

## Requirements

- Raspberry Pi or another machine with Bluetooth support.
- TI SensorTag hardware.
- Redis for the queue-based Node examples.
- Older Node/Python dependencies; review and update before exposing this to a network.

## Related Posts

- <http://iamsensoria.com/post/133678102011/raspberry-pi-and-sensor-tag>
- <http://iamsensoria.com/post/134068331553/raspberry-pi-and-sensor-tag-part-ii>
- <http://iamsensoria.com/post/134004915304/raspberry-pi-and-sensor-tag-part-iii>
