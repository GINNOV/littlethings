// FILE: src/components/LayerSelector.js
import React from 'react';

const LayerSelector = ({ layers, activeLayer, setActiveLayer }) => {
  const handleLayerChange = (e) => {
    const value = e.target.value === 'all' ? 'all' : Number(e.target.value);
    setActiveLayer(value);
  };

  return (
    <div className="selector-wrapper">
      <label htmlFor="layer-select">Concentrati su:</label>
      <select id="layer-select" value={activeLayer} onChange={handleLayerChange}>
        <option value="all">Mostra tutti gli strati</option>
        {Object.entries(layers).map(([layerNum, layerData]) => (
          <option key={layerNum} value={layerNum}>
            Strato {layerNum}: {layerData.name}
          </option>
        ))}
      </select>
    </div>
  );
};
export default LayerSelector;