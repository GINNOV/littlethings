# FDI Mouth Chart Selector

A lightweight, responsive, and framework-free suite of web tools for interactive dental charting using the **FDI World Dental Federation notation** (ISO 3950). 

It features responsive coordinate mapping, click-to-select sensitivity, and a built-in calibration tool to easily adapt to custom dental illustrations.

---

## 📖 Narrative

In clinical dental software, enabling users (dentists, assistants, or patients) to select specific teeth on a visual mouth chart is a common requirement. However, most existing libraries are heavy, framework-dependent, or use absolute pixel coordinate maps that break on responsive web layouts.

**FDI Mouth Chart Selector** solves this with a pure-client-side, zero-dependency implementation. By mapping coordinates as **percentages** and layering an SVG overlay over a responsive image, the selection circle remains perfectly aligned to the correct teeth across all screen sizes (desktop, tablet, or mobile).

---

## 🛠️ Technical Details

### 1. The FDI Numbering System
The chart utilizes the standard FDI two-digit numbering system, dividing the mouth into 4 quadrants (1 = Upper Right, 2 = Upper Left, 3 = Lower Left, 4 = Lower Right) and numbering teeth 1 to 8 starting from the midline:
* **Maxillary Right (Quadrant 1):** Teeth 18 to 11
* **Maxillary Left (Quadrant 2):** Teeth 21 to 28
* **Mandibular Left (Quadrant 3):** Teeth 31 to 38
* **Mandibular Right (Quadrant 4):** Teeth 41 to 48

### 2. Responsive Coordinate Mapping
Instead of hardcoding pixel coordinates (e.g., `x: 300px, y: 150px`), tooth positions are stored as percentages of the parent container’s width and height.
* The SVG overlay uses a `viewBox="0 0 100 100"` with `preserveAspectRatio="none"`.
* When a coordinate `{ x: 46.4, y: 10.7 }` is applied, the SVG circle places its center (`cx`, `cy`) at those exact percentage markers.
* The underlying chart image scales fluidly, and the SVG scales identically with it.

### 3. Click Detection via Euclidean Distance
To allow users to click directly on a tooth in the diagram, a click handler computes the distance to all mapped teeth using the Euclidean distance formula:

$$d = \sqrt{(x_{\text{click}} - x_{\text{tooth}})^2 + (y_{\text{click}} - y_{\text{tooth}})^2}$$

If the shortest distance is within the sensitivity threshold (default is $6\%$ of the chart dimensions), that tooth is selected.

---

## 📂 File Guide

* **[main.html](./main.html):** Standard picker combining a dropdown menu with a responsive, clickable chart. Selecting via either UI element updates the other.
* **[tooth_mouse_selector.html](./tooth_mouse_selector.html):** Clean, click-only interface that updates a simple text indicator badge instead of a dropdown menu.
* **[tooth_calibration.html](./tooth_calibration.html):** Calibration utility. Enable *Manual Calibration*, select a tooth, and click on the image to update or redefine its coordinates. Copy the generated JSON map directly from the text area.

---

## 🚀 Integration Guide

### 1. Vanilla HTML / CSS / JS Integration
To embed the selector in an existing web page, structure your HTML and CSS as follows:

```html
<!-- Chart Container -->
<div class="chart-container" style="position: relative; max-width: 650px; width: 100%;">
  <!-- Anatomical Chart Image -->
  <img src="fdi_mouth_chart.png" alt="Dental Chart" style="width: 100%; height: auto; display: block;" />

  <!-- SVG Selection Overlay -->
  <svg id="chart-overlay" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none;" viewBox="0 0 100 100" preserveAspectRatio="none">
    <circle id="selection-indicator" cx="0" cy="0" r="3.5" style="opacity: 0; fill: none; stroke: #e74c3c; stroke-width: 0.5; transition: all 0.2s;" />
  </svg>
</div>
```

Then, hook up the coordinate map and click listener:

```javascript
const toothMap = {
  11: { x: 46.4, y: 10.7 },
  12: { x: 41.8, y: 11.4 },
  // ... rest of coordinates (see main.html for full mapping)
};

const container = document.querySelector('.chart-container');
const indicator = document.getElementById('selection-indicator');

container.addEventListener('click', (e) => {
  const rect = container.getBoundingClientRect();
  const clickX = ((e.clientX - rect.left) / rect.width) * 100;
  const clickY = ((e.clientY - rect.top) / rect.height) * 100;

  let closestTooth = null;
  let minDistance = Infinity;
  const clickSensitivity = 6.0;

  for (const [toothNum, pos] of Object.entries(toothMap)) {
    const dist = Math.sqrt(Math.pow(clickX - pos.x, 2) + Math.pow(clickY - pos.y, 2));
    if (dist < minDistance) {
      minDistance = dist;
      closestTooth = toothNum;
    }
  }

  if (closestTooth && minDistance <= clickSensitivity) {
    selectTooth(closestTooth);
  }
});

function selectTooth(toothNumber) {
  const pos = toothMap[toothNumber];
  indicator.setAttribute('cx', pos.x);
  indicator.setAttribute('cy', pos.y);
  indicator.style.opacity = '1';
  
  // Dispatch custom event for your application to consume
  container.dispatchEvent(new CustomEvent('toothSelected', { detail: { tooth: toothNumber } }));
}
```

### 2. React / Next.js Component Integration
Here is how you can wrap this logic in a modern React component:

```tsx
import React, { useState, useRef } from 'react';

const TOOTH_COORDINATES: Record<string, { x: number; y: number }> = {
  11: { x: 46.4, y: 10.7 },
  12: { x: 41.8, y: 11.4 },
  // ... paste full JSON coordinate mapping from main.html
};

interface DentalChartProps {
  onToothSelect?: (tooth: string) => void;
}

export const DentalChart: React.FC<DentalChartProps> = ({ onToothSelect }) => {
  const [selectedTooth, setSelectedTooth] = useState<string | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  const handleChartClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!containerRef.current) return;

    const rect = containerRef.current.getBoundingClientRect();
    const clickX = ((e.clientX - rect.left) / rect.width) * 100;
    const clickY = ((e.clientY - rect.top) / rect.height) * 100;

    let closestTooth = null;
    let minDistance = Infinity;
    const threshold = 6;

    for (const [toothNum, pos] of Object.entries(TOOTH_COORDINATES)) {
      const dist = Math.sqrt(Math.pow(clickX - pos.x, 2) + Math.pow(clickY - pos.y, 2));
      if (dist < minDistance) {
        minDistance = dist;
        closestTooth = toothNum;
      }
    }

    if (closestTooth && minDistance <= threshold) {
      setSelectedTooth(closestTooth);
      if (onToothSelect) onToothSelect(closestTooth);
    }
  };

  const selectedPos = selectedTooth ? TOOTH_COORDINATES[selectedTooth] : null;

  return (
    <div 
      ref={containerRef} 
      onClick={handleChartClick}
      style={{ position: 'relative', width: '100%', maxWidth: '650px', cursor: 'pointer' }}
    >
      <img src="/fdi_mouth_chart.png" alt="Dental Chart" style={{ width: '100%', display: 'block' }} />
      <svg 
        style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', pointerEvents: 'none' }}
        viewBox="0 0 100 100" 
        preserveAspectRatio="none"
      >
        {selectedPos && (
          <circle 
            cx={selectedPos.x} 
            cy={selectedPos.y} 
            r="3.5" 
            fill="none" 
            stroke="#e74c3c" 
            strokeWidth="0.5" 
          />
        )}
      </svg>
    </div>
  );
};

---

## 🎯 How to Calibrate and Leverage Coordinates

If you decide to replace `fdi_mouth_chart.png` with a different image style, layout, or sizing, you will need to re-calibrate the coordinates of each tooth. Follow these steps to generate and apply your custom coordinates:

### Step 1: Generate the Coordinates via Calibration UI
1. Open `tooth_calibration.html` in any web browser.
2. Check the **"Enable Manual Calibration"** box under the *Calibration Mode* panel.
3. Select a tooth from the **"Select Tooth (FDI)"** dropdown list (e.g., Tooth `11`).
4. Click on the center of that tooth directly on the dental chart image. You will see the green circle overlay jump to where you clicked.
5. Repeat this process for all 32 teeth. The JSON output in the text field labeled **"Current Coordinates (JSON)"** will update in real time.

### Step 2: Extract the JSON Coordinates
Once all teeth have been calibrated, select and copy the complete JSON object from the **"Current Coordinates (JSON)"** textarea. It will look like this:

```json
{
    "11": { "x": 46.4, "y": 10.7 },
    "12": { "x": 41.8, "y": 11.4 },
    ...
}
```

### Step 3: Integrate and Place the Coordinates in Your Project
Paste this JSON block directly into your source code to replace the default coordinates:

* **In Vanilla JS:** Assign the copied object to your `toothMap` configuration variable:
  ```javascript
  const toothMap = {
      // Paste your copied JSON block here
  };
  ```
* **In React / TypeScript:** Assign it to the `TOOTH_COORDINATES` constant or import it from a separate config file:
  ```typescript
  const TOOTH_COORDINATES: Record<string, { x: number; y: number }> = {
      // Paste your copied JSON block here
  };
  ```

### Step 4: Adjust Sensitivity Threshold
If you find that the click detection is too strict or too loose:
1. In the `addEventListener('click')` (or `handleChartClick` method), locate the threshold variable (e.g., `const clickSensitivity = 6.0` or `const threshold = 6`).
2. **Increase** the value (e.g., to `8.0` or `10.0`) if users have difficulty clicking small targets.
3. **Decrease** the value (e.g., to `4.0` or `5.0`) if clicks on one tooth are incorrectly selecting adjacent teeth.
```
