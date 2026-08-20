export class SmartPartPlanner {
  analyze(parts) {
    const valid = parts.filter(Boolean);
    const count = Math.max(1, valid.length);
    const connectors = Math.max(0, (count - 1) * 2);
    const complexity = count <= 3 ? 'BALANCED' : count <= 6 ? 'MULTI-PART' : 'COMPLEX';
    return {
      partCount: count,
      connectorCount: connectors,
      plan: complexity,
      printability: 'READY',
      strategy: count <= 3 ? 'Keep the model in large printable sections.' : 'Divide along natural interfaces and preserve alignment references.'
    };
  }

  recommendSplit({width, height, depth, maxBuildSize = 220}) {
    const dimensions = [width, height, depth].filter(Number.isFinite);
    if (!dimensions.length) return { sections: 1, axis: 'none', reason: 'Insufficient geometry data.' };
    const largest = Math.max(...dimensions);
    if (largest <= maxBuildSize) return { sections: 1, axis: 'none', reason: 'Model fits within the configured build envelope.' };
    const axis = dimensions.indexOf(largest) === 0 ? 'X' : dimensions.indexOf(largest) === 1 ? 'Y' : 'Z';
    return {
      sections: Math.ceil(largest / maxBuildSize),
      axis,
      reason: `Split along ${axis} to keep each section within the build envelope.`
    };
  }
}
