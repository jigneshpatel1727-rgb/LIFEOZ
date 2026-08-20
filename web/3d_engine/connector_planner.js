export class ConnectorPlanner {
  plan(parts, options = {}) {
    const gap = Number.isFinite(options.gap) ? options.gap : 0.02;
    const diameter = Number.isFinite(options.diameter) ? options.diameter : 4;
    const joints = [];
    for (let i = 0; i < Math.max(0, parts.length - 1); i++) {
      const a = parts[i];
      const b = parts[i + 1];
      joints.push({
        id: `joint-${i + 1}`,
        from: a?.id ?? i,
        to: b?.id ?? i + 1,
        type: 'alignment-pin',
        diameter,
        clearance: gap,
        orientation: 'normal-to-interface'
      });
    }
    return { joints, count: joints.length, status: joints.length ? 'PLANNED' : 'NO_JOINTS' };
  }
}
