# Sleepia

Sleepia is a small collection of experiments around collecting and rendering sleep-related data. The code is historical and reflects the tools used for the original experiments.

## Files

| File | Purpose |
| --- | --- |
| `slogger.js` | Collects temperature and movement data with a TI SensorTag. |
| `package.json` | Older Node dependencies for the SensorTag logger. |

## Requirements

- TI SensorTag hardware for `slogger.js`.
- Bluetooth support on the host machine.
- Redis and older Node dependencies for the queue-based workflow.

## Notes

- Review dependencies before running this on a modern system.
- Keep personal sleep or health data private; do not commit captured data files.
- Treat the scripts as experiment material rather than a maintained health product.

## Related Posts

- Read EDF Files: <http://iamsensoria.com/post/131753663431/read-edf-files>
- Slogger, collect data with SensorTag: <http://iamsensoria.com/post/134004915304/raspberry-pi-and-sensor-tag-part-iii>
