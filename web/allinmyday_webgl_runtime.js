/* ALLINMYDAY-owned native WebGL runtime. No 3D framework or CDN is required. */
export class AllinmydayWebGLRuntime {
  constructor(canvas) {
    this.canvas = canvas;
    this.gl = canvas.getContext('webgl', { antialias: true, alpha: false });
    if (!this.gl) throw new Error('WebGL unavailable');
    this.rotationX = 0;
    this.rotationY = 0;
    this.targetX = 0;
    this.targetY = 0;
    this.points = [];
    this.program = this.#createProgram();
    this.position = this.gl.getAttribLocation(this.program, 'a_position');
    this.mvp = this.gl.getUniformLocation(this.program, 'u_mvp');
    this.color = this.gl.getUniformLocation(this.program, 'u_color');
    this.size = this.gl.getUniformLocation(this.program, 'u_size');
    this.buffer = this.gl.createBuffer();
    this.resize();
    addEventListener('resize', () => this.resize());
  }

  addPoint(x, y, z, color, size = 8) {
    this.points.push({ x, y, z, color, size });
  }

  setRotation(x, y) {
    this.targetX = Math.max(-0.7, Math.min(0.7, x));
    this.targetY = y;
  }

  resize() {
    const dpr = Math.min(devicePixelRatio || 1, 2);
    this.canvas.width = Math.max(1, Math.floor(innerWidth * dpr));
    this.canvas.height = Math.max(1, Math.floor(innerHeight * dpr));
    this.gl.viewport(0, 0, this.canvas.width, this.canvas.height);
  }

  render(time = 0) {
    const gl = this.gl;
    this.rotationX += (this.targetX - this.rotationX) * 0.08;
    this.rotationY += (this.targetY - this.rotationY) * 0.08;
    gl.clearColor(0.008, 0.02, 0.043, 1);
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    gl.useProgram(this.program);
    for (const point of this.points) {
      const p = this.#transform(point.x, point.y, point.z, this.rotationX, this.rotationY);
      gl.bindBuffer(gl.ARRAY_BUFFER, this.buffer);
      gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(p), gl.STREAM_DRAW);
      gl.enableVertexAttribArray(this.position);
      gl.vertexAttribPointer(this.position, 3, gl.FLOAT, false, 0, 0);
      gl.uniformMatrix4fv(this.mvp, false, new Float32Array(this.#projection()));
      gl.uniform4fv(this.color, point.color);
      gl.uniform1f(this.size, point.size);
      gl.drawArrays(gl.POINTS, 0, 1);
    }
    this.points.length = 0;
    return time;
  }

  #transform(x, y, z, rx, ry) {
    const cy = Math.cos(ry), sy = Math.sin(ry), cx = Math.cos(rx), sx = Math.sin(rx);
    const xx = x * cy - z * sy;
    const zz = x * sy + z * cy;
    return [xx, y * cx - zz * sx, y * sx + zz * cx - 12];
  }

  #projection() {
    const aspect = this.canvas.width / this.canvas.height;
    const f = 1 / Math.tan(Math.PI / 6);
    const n = 0.1, far = 100, nf = 1 / (n - far);
    return [f / aspect,0,0,0, 0,f,0,0, 0,0,(far+n)*nf,-1, 0,0,(2*far*n)*nf,0];
  }

  #createProgram() {
    const gl = this.gl;
    const vertex = this.#shader(gl.VERTEX_SHADER, 'attribute vec3 a_position; uniform mat4 u_mvp; uniform float u_size; void main(){gl_Position=u_mvp*vec4(a_position,1.0);gl_PointSize=u_size;}');
    const fragment = this.#shader(gl.FRAGMENT_SHADER, 'precision mediump float; uniform vec4 u_color; void main(){float d=distance(gl_PointCoord,vec2(.5));if(d>.5)discard;gl_FragColor=u_color;}');
    const program = gl.createProgram();
    gl.attachShader(program, vertex); gl.attachShader(program, fragment); gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) throw new Error(gl.getProgramInfoLog(program));
    return program;
  }

  #shader(type, source) {
    const gl = this.gl, shader = gl.createShader(type);
    gl.shaderSource(shader, source); gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) throw new Error(gl.getShaderInfoLog(shader));
    return shader;
  }
}
